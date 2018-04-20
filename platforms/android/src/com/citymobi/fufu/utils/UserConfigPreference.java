package com.citymobi.fufu.utils;

import android.content.Context;
import android.content.SharedPreferences;

import com.citymobi.fufu.entity.UserConfig;

/**
 * 用户配置
 * Created by ZQ on 2017/2/10.
 */

public class UserConfigPreference {
    private SharedPreferences mPreferences;
    private SharedPreferences.Editor mEditor;

    public UserConfigPreference(Context context) {
        mPreferences = context.getSharedPreferences("UserConfig", Context.MODE_PRIVATE);
        mEditor = mPreferences.edit();
    }

    public String getJPushMessage() {
        return mPreferences.getString(UserConfig.JPUSH_MESSAGE, "");
    }

    public UserConfigPreference saveJPushMessage(String jpushMessage) {
        mEditor.putString(UserConfig.JPUSH_MESSAGE, jpushMessage);
        return this;
    }

    /**
     * 最终保存方法（不调用则不保存）
     */
    public UserConfigPreference apply() {
        mEditor.apply();
        return this;
    }

    /**
     * 移除某个key值已经对应的值
     *
     * @param key
     * @return
     */
    public UserConfigPreference remove(String key) {
        mEditor.remove(key);
        return this;
    }

    public void clear() {
        mEditor.clear();
        mEditor.apply();
    }
}
