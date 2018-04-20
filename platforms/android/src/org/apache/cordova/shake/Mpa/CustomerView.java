package org.apache.cordova.shake.Mpa;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.View;

/**
 * Created by shangzh on 16/6/27.
 */
public class CustomerView extends View {

    private Paint mPaint;

    public CustomerView(Context context, AttributeSet attrs) {
        super(context, attrs);
        mPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        mPaint.setColor(Color.WHITE);
        canvas.drawRect(0, 0, getWidth(), getHeight(), mPaint);
        mPaint.setColor(Color.BLACK);
        mPaint.setTextSize(20);
        String text = "加载中......";
        canvas.drawText(text, getWidth()/2, getHeight()/2, mPaint);
    }
}
