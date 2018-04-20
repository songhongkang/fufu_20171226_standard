package org.apache.cordova.shake.Mpa;

import android.content.Context;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.animation.Animation;
import android.view.animation.AnimationSet;
import android.view.animation.ScaleAnimation;
import android.view.animation.TranslateAnimation;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.citymobi.fufu.R;

/**
 * Created by shangzh on 16/6/25.
 */
public class CustomerSearchBar extends EditText {

    private final static String TAG = "EditTextWithDel";
    private Drawable imgInable;
    private Drawable delInable;
    private Drawable imgAble;
    private Context mContext;
    private ViewGroup.LayoutParams layoutParams;
    private int screenWidth;


    public CustomerSearchBar(Context context) {
        super(context);
        mContext = context;
        init();
    }

    public CustomerSearchBar(Context context, AttributeSet attrs) {
        super(context, attrs);
        mContext = context;
        init();
    }

    public CustomerSearchBar(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        mContext = context;
        init();
    }

    private void init() {
        WindowManager wm = (WindowManager) mContext.getSystemService(Context.WINDOW_SERVICE);
        screenWidth = wm.getDefaultDisplay().getWidth();//屏幕宽度

        imgInable = mContext.getResources().getDrawable(R.drawable.ion_search);
        delInable = mContext.getResources().getDrawable(R.drawable.deleate);
        addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                setDrawable();
            }
        });
        setDrawable();

        this.setOnFocusChangeListener(new OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {

            }
        });
    }

    // 设置删除图片
    private void setDrawable() {
        if (length() < 1)
            setCompoundDrawablesWithIntrinsicBounds(imgInable, null, null, null);
        else
        setCompoundDrawablesWithIntrinsicBounds(imgInable, null, null, null);
    }

    // 处理删除事件
    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (imgInable != null && event.getAction() == MotionEvent.ACTION_UP) {
            int eventX = (int) event.getRawX();
            int eventY = (int) event.getRawY();
            Rect rect = new Rect();
            getGlobalVisibleRect(rect);
            rect.left = rect.right - 100;
            if (rect.contains(eventX, eventY))
                setText("");
        }
        return super.onTouchEvent(event);
    }

    @Override
    protected void finalize() throws Throwable {
        super.finalize();
    }


    @Override
    protected void onFocusChanged(boolean focused, int direction, Rect previouslyFocusedRect) {
        super.onFocusChanged(focused, direction, previouslyFocusedRect);
    }


    public void moveToUp (final TextView view, final float density) {

        //初始化
        Animation translateAnimation = new TranslateAnimation(0.1f, 0.0f,0.1f,-80.0f);

        //初始化
        Animation scaleAnimation = new ScaleAnimation(1.0f, 0.88f,1.0f,1.0f);

        //动画集
        AnimationSet set = new AnimationSet(true);
        set.addAnimation(translateAnimation);
        set.addAnimation(scaleAnimation);

        //设置动画时间 (作用到每个动画)
        set.setDuration(500);
        this.startAnimation(set);

        set.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {

            }

            @Override
            public void onAnimationEnd(Animation animation) {
                clearAnimation();
                ViewGroup.MarginLayoutParams margin=new ViewGroup.MarginLayoutParams(getLayoutParams());
                margin.setMargins(margin.leftMargin+24,(int)(7.5*density) , margin.rightMargin+(int) (50*density), margin.height);
                RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(margin);
                setLayoutParams(layoutParams);
//                this.setLayoutParams(layoutParams);

                view.setVisibility(VISIBLE);

            }

            @Override
            public void onAnimationRepeat(Animation animation) {

            }
        });
    }

    public void moveToDown (final float density) {
        //初始化
        Animation translateAnimation = new TranslateAnimation(0.1f, 0.0f,0.1f,90.0f);

        //初始化
        Animation scaleAnimation = new ScaleAnimation(1.0f, 1.2f,1.0f,1.0f);

        //动画集
        AnimationSet set = new AnimationSet(true);
        set.addAnimation(translateAnimation);
        set.addAnimation(scaleAnimation);

        //设置动画时间 (作用到每个动画)
        set.setDuration(500);
        this.startAnimation(set);

        set.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {

            }

            @Override
            public void onAnimationEnd(Animation animation) {
//                Animation animation1 = new TranslateAnimation(0,0,0,0);
                clearAnimation();
                ViewGroup.MarginLayoutParams margin=new ViewGroup.MarginLayoutParams(getLayoutParams());
                margin.setMargins(margin.leftMargin+24,(int) (50*density), margin.rightMargin+24, margin.height);
                RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(margin);
                setLayoutParams(layoutParams);

            }

            @Override
            public void onAnimationRepeat(Animation animation) {

            }
        });
    }
}
