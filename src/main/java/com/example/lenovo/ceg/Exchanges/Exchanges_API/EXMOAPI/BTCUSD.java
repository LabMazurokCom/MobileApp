
package com.example.lenovo.ceg.Exchanges.Exchanges_API.EXMOAPI;

import java.util.List;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class BTCUSD {

    @SerializedName("ask_quantity")
    @Expose
    private String askQuantity;
    @SerializedName("ask_amount")
    @Expose
    private String askAmount;
    @SerializedName("ask_top")
    @Expose
    private String askTop;
    @SerializedName("bid_quantity")
    @Expose
    private String bidQuantity;
    @SerializedName("bid_amount")
    @Expose
    private String bidAmount;
    @SerializedName("bid_top")
    @Expose
    private String bidTop;
    @SerializedName("ask")
    @Expose
    private List<List<Float>> ask = null;
    @SerializedName("bid")
    @Expose
    private List<List<Float>> bid = null;

    public String getAskQuantity() {
        return askQuantity;
    }

    public void setAskQuantity(String askQuantity) {
        this.askQuantity = askQuantity;
    }

    public String getAskAmount() {
        return askAmount;
    }

    public void setAskAmount(String askAmount) {
        this.askAmount = askAmount;
    }

    public String getAskTop() {
        return askTop;
    }

    public void setAskTop(String askTop) {
        this.askTop = askTop;
    }

    public String getBidQuantity() {
        return bidQuantity;
    }

    public void setBidQuantity(String bidQuantity) {
        this.bidQuantity = bidQuantity;
    }

    public String getBidAmount() {
        return bidAmount;
    }

    public void setBidAmount(String bidAmount) {
        this.bidAmount = bidAmount;
    }

    public String getBidTop() {
        return bidTop;
    }

    public void setBidTop(String bidTop) {
        this.bidTop = bidTop;
    }

    public List<List<Float>> getAsk() {
        return ask;
    }

    public void setAsk(List<List<Float>> ask) {
        this.ask = ask;
    }

    public List<List<Float>> getBid() {
        return bid;
    }

    public void setBid(List<List<Float>> bid) {
        this.bid = bid;
    }

}
