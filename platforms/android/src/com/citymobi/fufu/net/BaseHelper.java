package com.citymobi.fufu.net;

import android.text.TextUtils;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Created by ZhonQuan on 2017/1/12 0020
 * 参数打印工具
 */

public class BaseHelper {

    public static String getParams(Map<String, String> requst) {
        StringBuffer param = new StringBuffer();
        // String url = makeBaseUrl(module);

        List<String> keyList = new ArrayList<String>();
        {
            Set set = requst.keySet();
            Iterator it = set.iterator();
            while (it.hasNext()) {
                String key = (String) it.next();
                keyList.add(key);
            }
        }

        for (int i = 0; i < keyList.size(); i++) {

            String key = keyList.get(i);
            String val = requst.get(key);

            if (TextUtils.isEmpty(param)) {
                param.append("?" + key + "=" + val);
            } else {
                param.append("&" + key + "=" + val);
            }
        }

        keyList = null;

        if (param == null) return null;
        return param.toString();
    }
}
