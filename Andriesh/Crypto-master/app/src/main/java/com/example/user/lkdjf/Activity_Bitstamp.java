package com.example.user.lkdjf;

import android.graphics.Color;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Gravity;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.widget.TextView;
import android.widget.Toast;

import com.github.mikephil.charting.charts.LineChart;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.LineData;
import com.github.mikephil.charting.data.LineDataSet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import retrofit2.Call;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class Activity_Bitstamp extends AppCompatActivity {
////
    public GetInterface getInterface;
    public Retrofit retrofit;
    public Bitstamp data;
    public float timeIndex=0;
    public String current_pair="btcusd";
    Response<Bitstamp> res;
    public ArrayList<Bitstamp> bidList = new ArrayList<>();
    public BitstampAPI gow = new BitstampAPI();
    String num1=new String();
    String num2=new String();
    String num3=new String();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.bitstamp);
        retrofit = new Retrofit.Builder().baseUrl("https://www.bitstamp.net").addConverterFactory(GsonConverterFactory.create()).build();
        getInterface = retrofit.create(GetInterface.class);
        gow.execute();
        TextView v=findViewById(R.id.text1);
        v.setText("Bitcoin (BTC)");
    }

    @Override
    protected void onStart(){
        super.onStart();
        if(gow==null) {
            gow.execute();
            timeIndex = 0;
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.menu, menu);
        return true;
    }

    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.bchusd:
                current_pair = "bchusd";
                timeIndex = 0;
                TextView v=findViewById(R.id.text1);
                v.setText("Bitcoin Cash (BCH)");
                bidList.clear();
                break;
            case R.id.btcusd:
                current_pair = "btcusd";
                timeIndex = 0;
                TextView v1=findViewById(R.id.text1);
                v1.setText("Bitcoin (BTC)");
                bidList.clear();
                break;
            case R.id.ethusd:
                current_pair = "ethusd";
                timeIndex = 0;
                TextView v2=findViewById(R.id.text1);
                v2.setText("Ethereum (ETH)");
                bidList.clear();
                break;
          /*  case R.id.xmrusd:
                current_pair = "xmrusd";
                timeIndex = 0;
                TextView v3=findViewById(R.id.text1);
                v3.setText("Monero (XMR)");
                bidList.clear();
                break;
            case R.id.ltcusd:
                current_pair = "ltcusd";
                timeIndex = 0;
                TextView v4=findViewById(R.id.text1);
                v4.setText("Litecoin (LTC)");
                bidList.clear();
                break;*/
        }
        return super.onOptionsItemSelected(item);
    }

    class BitstampAPI extends AsyncTask<Void, Response<Bitstamp>, Response<Bitstamp>> {

        @Override
        protected Response<Bitstamp> doInBackground(Void... voids) {
            res = null;
            while (!isCancelled()) {
                try {
                    Call<Bitstamp> responseCall = getInterface.getData(current_pair);
                    res = responseCall.execute();

                } catch (IOException e) { }
                res.body().setTimestamp(String.valueOf(timeIndex));
                publishProgress(res);
                try {
                    timeIndex = timeIndex + 1;
                    Thread.sleep(5000);
                } catch (InterruptedException e1) {
                    e1.printStackTrace();
                }
            }
            return res;
        }

        @Override
        protected void onProgressUpdate(Response<Bitstamp>... bitstampResponse) {
            super.onProgressUpdate(bitstampResponse);
            data = bitstampResponse[0].body();
            bidList.add(data);

            List<Entry> bidEntries = new ArrayList<>();
            List<Entry> askEntries = new ArrayList<>();
            List<Entry> lastEntries = new ArrayList<>();
            for (Bitstamp i : bidList) {
                Float bid = i.getBid();
                num1=""+bid;
                Float ask = i.getAsk();
                num2=""+ask;
                Float last = i.getLast();
                num3=""+last;
                Float timestamp = i.getTimestamp();

                lastEntries.add(new Entry(timestamp, last));
                bidEntries.add(new Entry(timestamp, bid));
                askEntries.add(new Entry(timestamp, ask));
            }
            TextView v2=findViewById(R.id.text2);
            v2.setText("Bid: "+ " "+ num1 + "\n" + "\n"+ "Ask: "+ " "+num2 + "\n" + "\n"+ "Last: "+ " " +num3);
            LineDataSet bidChart = new LineDataSet(bidEntries, "Bid");
            bidChart.setColor(Color.GREEN);

            LineDataSet askChart = new LineDataSet(askEntries, "Ask");
            askChart.setColor(Color.RED);

            LineDataSet lastChart = new LineDataSet(lastEntries, "Last Price");
            lastChart.setColor(Color.BLACK);

            LineChart chart = findViewById(R.id.lineChart);

            LineData chartData = new LineData();
            chartData.addDataSet(bidChart);
            chartData.addDataSet(askChart);
            chartData.addDataSet(lastChart);
            chart.setData(chartData);
            if(timeIndex<1){
                chart.fitScreen();
            }
            chart.getAxisLeft().setEnabled(false);
            chart.getXAxis().setAxisMinimum(0);
            chart.getXAxis().setAxisMaximum(1+timeIndex);
            chart.setVisibleXRangeMaximum (8);
            chart.moveViewToX(timeIndex);
        }

        @Override
        protected void onPostExecute(Response<Bitstamp> bitstampResponse) {
            super.onPostExecute(bitstampResponse);
        }
    }

    @Override
    protected void onStop(){
        super.onStop();
        if(gow!=null){
            gow.cancel(true);
            timeIndex = 0;
        }
    }

}
