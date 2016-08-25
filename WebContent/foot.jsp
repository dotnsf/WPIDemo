<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.TimeZone" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.io.StringReader" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="org.json.simple.JSONArray" %>
<%@ page import="org.json.simple.JSONObject" %>
<%@ page import="org.json.simple.parser.*" %>
<%@ page import="org.apache.commons.codec.binary.*" %>
<%@ page import="org.apache.commons.httpclient.methods.*" %>
<%@ page import="twitter4j.*" %>
<%@ page import="twitter4j.auth.*" %>
<%@ page import="javax.xml.parsers.DocumentBuilder" %>
<%@ page import="javax.xml.parsers.DocumentBuilderFactory" %>
<%@ page import="org.w3c.dom.Document" %>
<%@ page import="org.w3c.dom.Element" %>
<%@ page import="org.w3c.dom.NodeList" %>
<%@ page import="org.xml.sax.InputSource" %>
<%@ page import="me.juge.wpidemo.*" %>
<%
	request.setCharacterEncoding("utf-8");
%>

<%
	App app0 = new App();
me.juge.wpidemo.User[] users0 = app0.getAllUsers();
%>

<div class="container" style="padding:20px 0">

<div><a href="javascript:void(0)" id="category_desc1" onclick="show_layer('desc1');"><b>
このサービスの内容
</b></a></div>
<div id="layer_desc1" style="display:none; position:relative;" class="close">
<b>Big 5（ビッグファイブ）</b>と呼ばれる手法で５つの要素に分けた性格分析を行うと同時に、自分の性格に近い人／遠い人を代表的なAKBメンバーの中から探して提示する、というサービスです。<br/>
あなたの知らない自分の性格に気付くことができるかもしれません。またあなたの性格と近いAKBメンバーやAKBメンバーがどういう人なのかを気付くヒントになるかもしれません。<br/>
なお、あくまで<b>ツイートに基づく性格分析</b>です。実際の行動に反映されているかどうか、そもそもツイート内容が本音かどうかは別問題です。怒らないでください（苦笑）。
</div>
<p/>

<div><a href="javascript:void(0)" id="category_desc2" onclick="show_layer('desc2');"><b>
性格分析を行うには？
</b></a></div>
<div id="layer_desc2" style="display:none; position:relative;" class="close">
まずツイッターアカウントを持っていることが前提条件となります。またそのアカウントで性格分析を行うのに充分な量のツイートが行われている必要もあります。ご了承ください。<p/>
ツイッターアカウントをお持ちの場合は、画面右上の <img src="t.png"/> 部分をクリックして、ツイッターアカウントでログインを行い、このアプリにデータを共有する旨に許可（認証）いただきます。
許可されると、このサービスでログインしたあなたのツイートを直近で最大400件取得し、その内容を元に Big 5 性格分析を行います。
</div>
<p/>

<div><a href="javascript:void(0)" id="category_desc3" onclick="show_layer('desc3');"><b>
"Big 5"とは
</b></a></div>
<div id="layer_desc3" style="display:none; position:relative;" class="close">
人間の性格を構成する５つの要素とされるものです。具体的には以下の５要素です：
<ol class="desc">
<li>Openness: 心の開放度合い、好奇心の強さ</li>
<li>Conscientiousness: まじめレベル、勤勉性</li>
<li>Extraversion: 外向性、人と騒ぐのが好き</li>
<li>Agreeableness: 協調性、空気を読む</li>
<li>Emotional range: 感情性、イライラしやすい、落ち込みやすい</li>
</ol>
５つの各要素の中も６つの子要素から成立しており、このサービスではそれぞれの子要素のレベルで性格を１点満点で分析します。</p>
なお、これらの各要素の点数は高い方がよい、というものではありません。これらの数値レベルを元に性格が構成される、その計算要素の１つという考えです。
</div>
<p/>

<div><a href="javascript:void(0)" id="category_desc4" onclick="show_layer('desc4');"><b>
性格が似ている／似ていないの判断基準
</b></a></div>
<div id="layer_desc4" style="display:none; position:relative;" class="close">
まず性格分析は<b>ツイッターのつぶやき</b>を元に行います。AKBメンバーの方々も、またこのサービスを利用する方も、最近の400件のツイートを取り出し、その内容から Big 5 性格分析を行います。
そして５つの各要素毎に、あなたの性格と各AKBメンバーの性格をベクトル距離の差で比較し、もっとも近い人ともっとも遠い人を探します。
</div>
<p/>

<div><a href="javascript:void(0)" id="category_desc5" onclick="show_layer('desc5');"><b>
どのように Big 5 性格分析を行うか？
</b></a></div>
<div id="layer_desc5" style="display:none; position:relative;" class="close">
<a target="_blank" href="http://bluemix.net/">IBM Bluemix</a> から提供されている <a target="_blank" href="https://www.ibm.com/smarterplanet/us/en/ibmwatson/developercloud/personality-insights.html">Personality Insights API</a> を利用します。同一人物が書いたメールやツイートといったテキストから使われている単語や文章の傾向を調べ、Big 5 それぞれの性格を数値で調べることができます。
</div>
<p/>

<div><a href="javascript:void(0)" id="category_desc6" onclick="show_layer('desc6');"><b>
比較対象とするAKBメンバー（と、そのツイート）
</b></a></div>
<div id="layer_desc6" style="display:none; position:relative;" class="close">
現在、以下の<%=users0.length%>人のAKBメンバーのツイートを元に性格分析がデータベース化されています。この内容とあなたのツイートを元に同じロジックで性格分析を行い、性格の近い人と遠い人を探します：<br/>
<ul class="desc">
<%
	for( int i = 0; i < users0.length; i ++ ){ 
  me.juge.wpidemo.User user0 = users0[i];
%>
<li>
<a target="_blank" href="http://twitter.com/<%= user0.getTw_id() %>"><img src="<%= app0.getProfileImageURL( user0.getTw_id() ) %>" width="24" height="24" title="<%= user0.getTw_id() %>"/></a> &nbsp; <a href="./person.jsp?id=<%= user0.getTw_id() %>"><%= user0.getName() %>(<%= user0.getTw_id() %>) さん</a>
</li>
<% 
} 
%>
</ul>
</div>
<p/>

</div>

<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-78225703-1', 'auto');
  ga('send', 'pageview');

</script>

