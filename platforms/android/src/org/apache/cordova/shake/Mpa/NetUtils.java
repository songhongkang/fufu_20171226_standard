package org.apache.cordova.shake.Mpa;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

/**
 * Created by shangzh on 16/7/31.
 */
public class NetUtils {

    public static String LOGIN_URL = "http://120.24.153.50//cb_hrms/index.cfm?event=ionicAction.ionicAction.getOutdoorMapData&_user_name=18680391411&_pass_word=A5DD89CC477FE32B264C41CA561D2BE8&_is_login=1&_notification_token=1104a89792aa5a1e120&_device_type=android&target_date=2016-07-30";

//    public static  String LOGIN_URL = "https://www.baidu.com/";
    public static String LoginByPost(String number,String passwd) {


        HttpURLConnection urlConnection = null;
        try {

            URL url = null;
            try {
                url = new URL(LOGIN_URL);
                try {
                    urlConnection = (HttpURLConnection) url.openConnection();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            } catch (MalformedURLException e) {
                e.printStackTrace();
            }


            urlConnection.setDoOutput(true);
            urlConnection.setChunkedStreamingMode(0);

            OutputStream out = null;
            try {
                out = new BufferedOutputStream(urlConnection.getOutputStream());
            } catch (IOException e) {
                e.printStackTrace();
            }
//            writeStream(out);

            InputStream in = null;
            try {
                in = new BufferedInputStream(urlConnection.getInputStream());
            } catch (IOException e) {
                e.printStackTrace();
            }

//            readStream(in);
        } finally {
            urlConnection.disconnect();
        }

        return "";
    }


    public static String loginOfGet(String username, String password) {
        HttpURLConnection conn = null;

//        String data = "username=" + URLEncoder.encode(username) + "&password="+ URLEncoder.encode(password);
        String url = LOGIN_URL;
        try {

            // 利用string url构建URL对象
            URL mURL = new URL(url);


             String PIC_URL = "http://d.hiphotos.baidu.com/image/pic/item/b03533fa828ba61e0bd9f7ef4534970a304e593e.jpg";
       String HTML_URL = "http://www.baidu.com";

                URL urlPIc = new URL(PIC_URL);
                HttpURLConnection conncetion = (HttpURLConnection) urlPIc.openConnection();
                // 设置连接超时为5秒
            conncetion.setConnectTimeout(5000);
                // 设置请求类型为Get类型
            conncetion.setRequestMethod("GET");
                // 判断请求Url是否成功
                if (conncetion.getResponseCode() != 200) {
                    throw new RuntimeException("请求url失败");
                }
                InputStream inStream = conncetion.getInputStream();
                byte[] bt = read(inStream);
                inStream.close();

        conncetion.disconnect();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {

            if (conn != null) {
                conn.disconnect();
            }
        }

        return null;
    }

    private static String getStringFromInputStream(InputStream is)
            throws IOException {
        ByteArrayOutputStream os = new ByteArrayOutputStream();
        // 模板代码 必须熟练
        byte[] buffer = new byte[1024];
        int len = -1;
        // 一定要写len=is.read(buffer)
        // 如果while((is.read(buffer))!=-1)则无法将数据写入buffer中
        while ((len = is.read(buffer)) != -1) {
            os.write(buffer, 0, len);
        }
        is.close();
        String state = os.toString();// 把流中的数据转换成字符串,采用的编码是utf-8(模拟器默认编码)
        os.close();
        return state;
    }


    public static byte[] read(InputStream inStream) throws Exception{
        ByteArrayOutputStream outStream = new ByteArrayOutputStream();
        byte[] buffer = new byte[1024];
        int len = 0;
        while((len = inStream.read(buffer)) != -1)
        {
            outStream.write(buffer,0,len);
        }
        inStream.close();
        return outStream.toByteArray();
    }


    public static void getHtml(String path) throws Exception {
        URL url = new URL("https://www.baidu.com");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setConnectTimeout(5000);
        conn.setRequestMethod("GET");


        conn.connect();

        if (conn.getResponseCode() == 200) {
            InputStream in = conn.getInputStream();
            byte[] data = read(in);
            String html = new String(data, "UTF-8");

//            return html;
        }
//        return null;
    }



    public static String getConnect(String urlPath) {
        HttpURLConnection connection = null;
        InputStream is = null;
        try {
            URL url = new URL(urlPath);
            //获得URL对象
            connection = (HttpURLConnection) url.openConnection();
            //获得HttpURLConnection对象
            connection.setRequestMethod("GET");
            // 默认为GET
            connection.setUseCaches(false);
            //不使用缓存
            connection.setConnectTimeout(10000);
            //设置超时时间
            connection.setReadTimeout(10000);
            //设置读取超时时间
            connection.setDoInput(true);

            //设置是否从httpUrlConnection读入，默认情况下是true;

            if (connection.getResponseCode() == HttpURLConnection.HTTP_OK) {
                //相应码是否为200
                is = connection.getInputStream();
                //获得输入流
                BufferedReader reader = new BufferedReader(new InputStreamReader(is));
                //包装字节流为字符流
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }

                return response.toString();
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (connection != null) {
                connection.disconnect();
                connection = null;
            }
            if (is != null) {
                try {
                    is.close();
                    is = null;
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        return null;
    }

    }
