CryptoHeaps - это программа для наблюдения и анализа изменений курса криптовалют на биржевом рынке. В приложении представлен ряд ведущих бирж Bitfinex, Bitstamp, CEX, а также топ-3 популярных валют в каждой из них Bitcoin, Bitcoin Cash, Ethereum. CryptoHeaps предоставляет наиточные значения по таким параметрам, как Bid (предложение), Ask (спрос), Last (последняя сделка), а их графическая интерпритация отлично демонстрирует колебания курса и взаимодействие трех основных показателей.


В своем проекте я использовала информацию с api трех бирж, причем данные поступали напрямую, поэтому в моей работе представлены, помимо основного `MainActivity`, еще три класса `Activity_Bitfinex`, `Activity_Bitstamp`, `Activity_CEX`. 
Рассмотрим алгоритм работы на примере биржи Bitstamp (т.к. остальные представители выполнены аналогично). Для него были разработаны еще два класса. 
Первый из них является `Bitstamp`. 
```java
package com.example.user.lkdjf;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class Bitstamp {

    @SerializedName("high")
    @Expose
    private String high;
    @SerializedName("last")
    @Expose
    private String last;
    @SerializedName("timestamp")
    @Expose
    private String timestamp;
    @SerializedName("bid")
    @Expose
    private String bid;
    @SerializedName("vwap")
    @Expose
    private String vwap;
    @SerializedName("volume")
    @Expose
    private String volume;
    @SerializedName("low")
    @Expose
    private String low;
    @SerializedName("ask")
    @Expose
    private String ask;
    @SerializedName("open")
    @Expose
    private String open;

    public String getHigh() {
        return high;
    }

    public void setHigh(String high) {
        this.high = high;
    }

    public Float getLast() {

        Float lastw  = Float.valueOf(last);
        return lastw;
    }

    public void setLast(String last) {
        this.last = last;
    }

    public Float getTimestamp() {
        Float timew  = Float.valueOf(timestamp);
        return timew;
    }

    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }

    public Float getBid() {
        Float bidw = Float.valueOf(bid);
        return bidw;
    }

    public void setBid(String bid) {
        this.bid = bid;
    }

    public String getVwap() {
        return vwap;
    }

    public void setVwap(String vwap) {
        this.vwap = vwap;
    }

    public String getVolume() {
        return volume;
    }

    public void setVolume(String volume) {
        this.volume = volume;
    }

    public String getLow() {
        return low;
    }

    public void setLow(String low) {
        this.low = low;
    }

    public Float getAsk() {
        Float askw = Float.valueOf(ask);
        return askw;
    }

    public void setAsk(String ask) {
        this.ask = ask;
    }

    public String getOpen() {
        return open;
    }

    public void setOpen(String open) {
        this.open = open;
    }

}
```

Основная его задача - это серилизация `JSON` в java-объекты. Данный перевод вышел успешно с помощью библиотеки `Gson`. На выходе мы получили класс с многочисленными методами, которые нам дают возможность считывать, изменять и получать готовые для дальнейшей работы объекты - бывшие элементы массива `JSON`. 
Сам же шаблон для массива `JSON` и перечень методов описан в интерфейсе `GetInterface`.

```java
package com.example.user.lkdjf;

import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.Path;

public interface GetInterface {
    @GET("/api/v2/ticker/{currency_pair}")
    Call<Bitstamp> getData(@Path("currency_pair") String currency_pair);
}
```

Вернемся к основному - классу `Activity_Bitstamp`. В первом же методе `onCreate()` задана основная часть функционала библиотеки `Retrofit`, которая используется для удобной работы с сервером.  Именно для этого объекта созданны ранее расмотренные классы. В `Builder()` мы указываем базовый `URL` и добавляем `Gson` конвертер, чтобы `Retrofit` сам смог сконвертировать `JSON` данные в объекты `Bitstamp`. В итоге `Retrofit` будет брать базовый `URL` из `Builder()`, присоединять к нему остаток пути, который мы указываем в `GET` в интерфейсе, и тем самым получать полную ссылку.


```java
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
```

Далее мы работаем с классом, который наследует `AsyncTask`. Его цель – это выполнение тяжелых задач и передача в UI-поток результатов работы. 
В `doInBackground` для синхронного  запроса мы используем метод `execute()` у объекта типа `Call`. В результате выполнения мы получаем объект типа `Response` (ответ). Чтобы таких ответов с биржи хватало  для постоянной динамической рисовки нашего графика, все это происходит в бесконечном цикле (пока наш созданный поток "жив") с периодичностью в 5 секунд `Thread.sleep(5000)`.


```java
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
```
Полученный Response мы передаем в метод `onProgressUpdate`, откуда мы можем уже получить распарсенный ответ методом `body()`. В данном случае это будет массив значений: `bitstampResponse[0].body()`. Дальнейшие действия лишь за рисовкой графика. Я использую библиотеку `MPAndroidChart`. Для начала создадим массив элементов типаё `Bitstamp`, после чего выудим оттуда еще три массива отдельных значений `Bid`, `Ask`, `Last`. Передадим эти данные объекту типа `LineChart` и построим график, который после передадим в UI-поток.


```java
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
```
Также в каждой бирже в меню представлены три валюты. Реализация на `java` выглядит следующим образом:

```java
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
        }
        return super.onOptionsItemSelected(item);
    }
    ```
Основная идея: это смена параметров, заданных в `URL` и удаление всех полученных ранее ответов с бирж.

Запустим работу, создав новый поток:

```java
public BitstampAPI gow = new BitstampAPI();  
gow.execute();
```

Последний вопрос остался за оформлением. Каждая новая биржа это новое `Activity`, по которому можно перейти по кнопке в `MainActivity`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout  xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".MainActivity"
    android:orientation="vertical">

    <Button
        android:id="@+id/bitstamp"
        android:layout_width="282dp"
        android:layout_height="wrap_content"
        android:layout_alignParentTop="true"
        android:layout_centerHorizontal="true"
        android:layout_marginTop="150dp"
        android:onClick="onClick"
        android:text="bitstamp"
        android:elevation="10dp"
        android:background="@android:drawable/dialog_holo_light_frame"/>

    <Button
        android:id="@+id/bitfinex"
        android:layout_width="282dp"
        android:layout_height="wrap_content"
        android:layout_alignParentTop="true"
        android:layout_centerHorizontal="true"
        android:layout_marginTop="225dp"
        android:onClick="onClick"
        android:text="bitfinex"
        android:elevation="10dp"
        android:background="@android:drawable/dialog_holo_light_frame"/>

    <Button
        android:id="@+id/cex"
        android:layout_width="282dp"
        android:layout_height="wrap_content"
        android:layout_alignParentTop="true"
        android:layout_centerHorizontal="true"
        android:layout_marginTop="300dp"
        android:onClick="onClick"
        android:text="CEX"
        android:elevation="10dp"
        android:background="@android:drawable/dialog_holo_light_frame"/>

    <TextView
        android:id="@+id/textView"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_alignParentTop="true"
        android:layout_alignStart="@+id/bitstamp"
        android:layout_marginTop="100dp"
        android:text="Select a stock exchange"
        android:textStyle="bold|italic"/>
</RelativeLayout >
```

Например, разметка `Activity_Bitstamp` имеет вид:

```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical">

    <com.github.mikephil.charting.charts.LineChart
        android:id="@+id/lineChart"
        android:layout_width="match_parent"
        android:layout_height="300dp"
        android:layout_alignParentStart="true"
        android:layout_alignParentTop="true"
        android:layout_gravity="center"
        android:layout_marginTop="45dp" />

    <TextView
        android:id="@+id/text1"
        android:textSize="17sp"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_alignParentStart="true"
        android:layout_alignParentTop="true"
        android:textStyle="bold|italic"
        android:layout_marginTop="8dp"/>

    <TextView
        android:id="@+id/text2"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_alignParentBottom="true"
        android:layout_centerHorizontal="true"
        android:layout_gravity="center"
        android:layout_marginBottom="84dp" />

</RelativeLayout>
```

Отдельный файл для меню также имеет вид:
```xml
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:id="@+id/btcusd"
        android:title="@string/btcusd" />
    <item android:id="@+id/bchusd"
        android:title="@string/bchusd"/>
    <item android:id="@+id/ethusd"
        android:title="ETHUSD" />
</menu>
```
