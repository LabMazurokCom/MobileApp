package com.course_project.profitmoneydiagram.asynctasks;

import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.preference.PreferenceManager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.Gravity;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.course_project.profitmoneydiagram.R;
import com.course_project.profitmoneydiagram.model.CompiledOrderBook;
import com.course_project.profitmoneydiagram.model.Deal;
import com.course_project.profitmoneydiagram.model.DealListData;
import com.course_project.profitmoneydiagram.model.OrderBookGetter;
import com.course_project.profitmoneydiagram.model.OutputDataSet;
import com.course_project.profitmoneydiagram.ui.DealListAdapter;
import com.course_project.profitmoneydiagram.ui.MainActivity;
import com.github.mikephil.charting.charts.LineChart;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.LineData;
import com.github.mikephil.charting.data.LineDataSet;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

//Creates new thread, gets data from markets and displays it.
public class SoloAsyncTask extends AsyncTask<Void, OutputDataSet, OutputDataSet> {

    private static final String LOGTAG = "SoloAsyncTask";
    private static final int TIMEFORREQUEST = 5;
    private static int updateRateSeconds = 10;

    private WeakReference<MainActivity> activityReference;
    private SharedPreferences sp;
    private String currencyPair;
    private String secondCurrency; //Second currency in the pair.

    private boolean newDataReadyToPublish = true;
    private int progress = 0; //step of progress bar updating

    public SoloAsyncTask(MainActivity activity) {

        this.activityReference = new WeakReference<>(activity);

        sp = PreferenceManager.getDefaultSharedPreferences(activityReference.get());

        Log.d(LOGTAG, "SOLO ASYNCTASK STARTED");
    }


    //Show a text message on the screan.
    private void showToast(String msg) {
        Toast toast = Toast.makeText(activityReference.get().getApplicationContext(),
                msg,
                Toast.LENGTH_LONG);
        toast.setGravity(Gravity.CENTER, 0, 0);
        TextView v = (TextView) toast.getView().findViewById(android.R.id.message);
        if (v != null) v.setGravity(Gravity.CENTER);
        toast.show();
    }

    //Gets updateRateSeconds value from settings.
    private void updateUpdateRateSeconds() {

        try {
            updateRateSeconds = Integer.parseInt(sp.getString("update_rate", "10"));
        } catch (java.lang.RuntimeException e) {
            Log.d(LOGTAG, "Wrong formated string: update rate");
            updateRateSeconds = 10;
        }
    }

    //Gets currencyPair value from settings.
    private void updateCurrencyPair() {

        currencyPair = "BTC/USD"; //Avoiding the NullPointerException during the first launch.
        currencyPair = sp.getString("currency_pares", "BTC/USD");
        secondCurrency = currencyPair.split("/")[1];
    }


    @Override
    protected OutputDataSet doInBackground(Void... params) {

        OrderBookGetter getter = new OrderBookGetter();

        while (!isCancelled()) {

            //Check if settings were changed.
            updateUpdateRateSeconds();
            updateCurrencyPair();

            //Get order books directly from markets.
            //Get at most <limit> top asks and bids from each market.
            int limit = Integer.parseInt(sp.getString("depth_limit", "50"));
            //Currency pair to trade.
            String currencyPair = sp.getString("currency_pares", "BTC/USD");
            //Get orderBook with top orders from all markets.
            CompiledOrderBook orderBook = getter.getCompiledOrderBook(limit,
                    activityReference,
                    currencyPair);

            Double profit = 0.0; //Profit that we can get.
            Double amount = 0.0; //Amount of money necessary to do it.
            //Points of the plot.
            ArrayList<Double> profitPoints = new ArrayList<>();
            ArrayList<Double> amountPoints = new ArrayList<>();
            //List of deals to make.
            ArrayList<Deal> deals = new ArrayList<>(); //List of deals that should be made.
            final Double alpha = 0.1;
            Double optimalAmount = 0.0;
            Double optimalProfit = 0.0;
            Integer num = -1;   //Number of deals to make.
            Double curK = -1.0; //Current K.

            Double prevAmount = 0.0;
            Double prevProfit = 0.0;
            Double firstK = -1.0; //First value of K.
            //iterators.
            int bx = 0, ax = 0;

            OutputDataSet outputDataSet = new OutputDataSet();

            while ((ax < orderBook.getAsks().size())
                    && (bx < orderBook.getBids().size())
                    //While we can make profit from the deal.
                    && (orderBook.getBids().get(bx).getPrice() > orderBook.getAsks().get(ax).getPrice())) {

                num += 1;

                Double bidAmount = orderBook.getBids().get(bx).getAmount(); //Amount of top bid.
                Double askAmount = orderBook.getAsks().get(ax).getAmount(); //Amount of top ask.
                if (bidAmount.equals(0.0)) {
                    bx += 1;
                    continue;
                }
                if (askAmount.equals(0.0)) {
                    ax += 1;
                    continue;
                }
                //Amount of currency to buy (sell).
                Double m = Math.min(bidAmount, askAmount);

                Double currentProfit = (orderBook.getBids().get(bx).getPrice()
                        - orderBook.getAsks().get(ax).getPrice()) * m;

                profit += currentProfit;
                amount += orderBook.getAsks().get(ax).getPrice() * m;

                profitPoints.add(profit);
                amountPoints.add(amount);

                deals.add(new Deal("Buy", orderBook.getAsks().get(ax).getMarketName()
                        , m, orderBook.getAsks().get(ax).getPrice()));
                deals.add(new Deal("Sell", orderBook.getBids().get(bx).getMarketName()
                        , m, orderBook.getBids().get(bx).getPrice()));

                //Take into account that we have made a deal and top bid and ask are changed.
                Double oldBidAmount = orderBook.getBids().get(bx).getAmount();
                Double oldAskAmount = orderBook.getAsks().get(ax).getAmount();
                orderBook.getBids().get(bx).setAmount(oldBidAmount - m);
                orderBook.getAsks().get(ax).setAmount(oldAskAmount - m);

                //Check if we have achieved the optimal point.
                if (num.equals(2)) {
                    firstK = (profit - prevProfit) / (amount - prevAmount);
                } else if (num > 1) {
                    curK = (profit - prevProfit) / (amount - prevAmount);
                    if (curK / firstK >= alpha) {
                        optimalAmount = amount;
                        optimalProfit = profit;
                    }
                }
                prevAmount = amount;
                prevProfit = profit;
            }

            //Put data into the resulting data set.
            outputDataSet.setProfit(profit);
            outputDataSet.setAmount(amount);
            outputDataSet.setOptimalAmount(optimalAmount);
            outputDataSet.setOptimalProfit(optimalProfit);
            outputDataSet.setAmountPoints(amountPoints);
            outputDataSet.setProfitPoints(profitPoints);
            outputDataSet.setDeals(deals);

            //Unite buy and sell deals made on same market into one deal.
            outputDataSet.uniteDealsMadeOnSameMarkets();

            //Display data.
            publishProgress(outputDataSet);

            //Wait before next data updating.
            newDataReadyToPublish = false;

            progress = 0;
            publishProgress(outputDataSet); //drop the progress bar to zero.


            for (double i = 0.1; i <= (updateRateSeconds + 0.1); i+=0.1) {

                try {
                    TimeUnit.MILLISECONDS.sleep(100);
                } catch (InterruptedException e) {
                    Log.e(LOGTAG, e.getMessage());
                }

                progress = (int)Math.round(100*i/updateRateSeconds);

                publishProgress(outputDataSet);
            }
            newDataReadyToPublish = true;
        }
        return null;
    }


    @Override
    protected void onProgressUpdate(OutputDataSet... params) {

        super.onProgressUpdate(params);
        OutputDataSet dataSet = params[0];
        Log.d(LOGTAG, "SoloAsyncTask RUNNING");

        if (!newDataReadyToPublish) {

            Log.e(LOGTAG, "Updating progress bar: " + progress);
            ProgressBar pb = activityReference.get().findViewById(R.id.progress_bar);
            pb.setProgress(progress, true);
        } else {

            Log.e(LOGTAG, "Publishing progress");
            if (dataSet.getDeals().size() <= 1) {
                showToast("No profit can be made.\nCheck Internet connection\nand number of active markets.");
                return;
            }

            //Display profit points on the diagram.
            LineChart chart = (LineChart) activityReference.get().findViewById(R.id.diagram);
            //Points of the plot.
            List<Entry> chartEntries = new ArrayList<>();
            //Fill the list of points.
            for (int i = 0; i < dataSet.getAmountPoints().size(); ++i) {

                chartEntries.add(new Entry(dataSet.getAmountPoints().get(i).floatValue()
                        , dataSet.getProfitPoints().get(i).floatValue()));
            }
            //Make a DataSet with ordinary points.
            LineDataSet ds = new LineDataSet(chartEntries, "Profit/Money Diagram");
            ds.setColor(R.color.colorPrimaryDark);
            ds.setCircleColors(activityReference.get()
                    .getResources().getColor(R.color.diagramCircleOrdinary));

            //Make a DataSet with optimal point.
            Float optimalAmount = dataSet.getOptimalAmount().floatValue();
            Float optimalProfit = dataSet.getOptimalProfit().floatValue();

            List<Entry> optimalChartEntries = new ArrayList<>();
            optimalChartEntries.add(new Entry(optimalAmount, optimalProfit));
            LineDataSet ds2 = new LineDataSet(optimalChartEntries, "");

            ds2.setColor(R.color.colorPrimaryDark);
            ds2.setCircleColors(activityReference.get()
                    .getResources().getColor(R.color.diagramCircleOptimal));

            LineDataSet[] lineDataSets = new LineDataSet[2];
            lineDataSets[0] = ds;
            lineDataSets[1] = ds2;
            LineData ld = new LineData(lineDataSets);

            chart.setData(ld);
            chart.getDescription().setText("Horizontal: amount; Vertical: profit");
            chart.getLegend().setEnabled(false);
            chart.invalidate();

            //Display optimal profit.
            ((TextView) activityReference.get().findViewById(R.id.profit_string))
                    .setText("Profit: " + (Math.round(optimalProfit * 100) / 100.0) + " " + secondCurrency);
            //Display optimal amount.
            ((TextView) activityReference.get().findViewById(R.id.amount_string))
                    .setText("Amount: " + (Math.round(optimalAmount * 100) / 100.0) + " " + secondCurrency);
            //Display current currency pair.
            ((TextView) activityReference.get().findViewById(R.id.currency_pair)).setText(currencyPair);

            //Prepare data about deals for displaying.
            DealListData dldata = new DealListData(dataSet);
            //Display it.
            RecyclerView list = activityReference.get().findViewById(R.id.iknowdaway);
            LinearLayoutManager llm = new LinearLayoutManager(activityReference.get());

            llm.setOrientation(LinearLayoutManager.VERTICAL);
            list.setLayoutManager(llm);
            list.setAdapter(new DealListAdapter(dldata));
        }
    }

}