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
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3c.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml">
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
<title>性格そっくりなAKBメンバー調査</title>
<script src="//code.jquery.com/jquery-2.0.3.min.js"></script>
<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css"/>
<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap-theme.min.css"/>
<script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.1.3/Chart.min.js"></script>

<link rel="shortcut icon" href="./favicon.png" type="image/png" />
<link rel="icon" href="./favicon.png" type="image/png" />
<link href="./favicon.png" rel="apple-touch-icon" />

<meta name="viewport" content="width=device-width,initial-scale=1" />
<meta name="apple-mobile-web-app-capable" content="yes" />

<!-- //og tags -->
<meta property="og:title" content="性格そっくりなAKBメンバー調査"/>
<meta property="og:type" content="website"/>
<meta property="og:url" content="http://akb-finder.mybluemix.net/"/>
<meta property="og:image" content="http://akb-finder.mybluemix.net/ogp.png"/>
<meta property="og:site_name" content="性格そっくりなAKBメンバー調査"/>
<meta property="og:description" content="自分でも気付かない性格をあなたがツイートした内容から判断します。また同じような性格のAKBメンバーや、全く異なる性格を持つAKBメンバーを探しだしてくれるサービスです。投票時の参考になるかも！？"/>
<!-- og tags// -->

<meta name="description" content="自分でも気付かない性格をあなたがツイートした内容から判断します。また同じような性格のAKBメンバーや、全く異なる性格を持つAKBメンバーを探しだしてくれるサービスです。投票時の参考になるかも！？"/>
<meta name="keywords" content="性格,そっくり,AKB,AKB48,SKE48,NMB48,HTK48,NGT48,SNH48,ワトソン,Watson、Personality,Insights,パーソナリティ,分析,ツイッター,Twitter,ツイート,つぶやき"/>

<style type="text/css">
*{
 margin: 0;
 padding: 0;
}

.navbar-fixed-top{
 position: fixed;
 top: 0;
 right: 0;
 left: 0;
 z-index: 1030;
 margin-bottom: 0;
 background-color: #428BCA;
 foreground-color: #ffffff;
}

body{
 background-color: #eee;
}

.desc{
 padding: 5px 50px 5px 50px;
}

.carnonactive{
  border-width: 0px;
}
.caractive{
  border-color: #ffcccc;
  border-width: thick;
  border-style: solid;
}

.letsvote{
  background-color: #ccffcc;
}

.votenotavailable{
  background-color: #ffffcc;
}

.match{
}
</style>
<%
	App app = new App();
Member me = null;
me.juge.wpidemo.User[] users = app.getAllUsers();
JSONObject obj = null;

String id = "";
String _id = request.getParameter( "id" );
if( _id != null && _id.length() > 0 ){
	id = _id;
}

JSONParser parser = new JSONParser();
try{
	obj = ( JSONObject )parser.parse( app.big5 );
}catch( Exception e ){
	e.printStackTrace();
}

if( id != null && id.length() > 0 ){
	me = app.getMember( id );
}
%>
<title><%=me.getName()%>さんと性格が近い／遠いAKBメンバー</title>
</head>
<body>

<nav class="navbar navbar-default">
 <div class="container-fluid">
  <div class="navbar-header">
   <a class="navbar-brand" href="./"><%=me.getName()%>さんと性格が近い／遠いAKBメンバー</a>
   <button class="navbar-toggle" data-toggle="collapse" data-target=".target">
    <span class="icon-bar"></span>
    <span class="icon-bar"></span>
    <span class="icon-bar"></span>
   </button>
  </div>
  <div class="collapse navbar-collapse target">
   <ul class="nav navbar-nav navbar-right">   
    <li>
<%
	String authorizationURL = null;
try{
	Twitter twitter = new TwitterFactory().getInstance();
	twitter.setOAuthConsumer( app.tw_consumer_key, app.tw_consumer_secret );
	RequestToken requestToken = twitter.getOAuthRequestToken( "http://tw-finder.mybluemix.net/" );

	String token = requestToken.getToken();
	String tokenSecret = requestToken.getTokenSecret();

	session.setAttribute( "token", token );
	session.setAttribute( "tokenSecret", tokenSecret );
	authorizationURL = requestToken.getAuthorizationURL();
%>
<a href="<%=authorizationURL%>" data-role="button" rel="external"><img src="t.png" border="0" title="login"/></a>
<%
	}catch( Exception e ){
	e.printStackTrace();
}
%>
    </li>
   </ul>
  </div>
 </div>
</nav>

<script type="text/javascript">
function show_layer( cat ){
	var objID = document.getElementById('layer_'+cat);
	if( objID.className == 'close' ){
		objID.style.display = 'block';
		objID.className = 'open';
	}else{
		objID.style.display = 'none';
		objID.className = 'close';
	}
}
</script> 

<%
 	if( me != null ){
 %>
<div class="container" style="padding:20px 0">


<%
	me.juge.wpidemo.User top_user0 = app.getUser( me.getTop_tw_id0() );
%>
<div style="font-size: 16px"><a href="javascript:void(0)" id="category_top0" onclick="show_layer('top0');">
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと性格が近いのは <%=top_user0.getName()%><img src="<%=app.getProfileImageURL( top_user0.getTw_id() )%>" width="24" height="24" title="<%=top_user0.getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=top_user0.getTw_id()%>">&gt;&gt;</a></div>

<div id="layer_top0" style="display:none; position:relative;" class="close">
<canvas id="chart_top0" width="400" height="400"></canvas>
<script>
$(function(){
  var ctx = $("#chart_top0");
  var data = {
    labels: [
    	"<%=( String )obj.get( "openness_adventurousness" )%>", "<%=( String )obj.get( "openness_artistic_interests" )%>", "<%=( String )obj.get( "openness_emotionality" )%>", "<%=( String )obj.get( "openness_imagination" )%>", "<%=( String )obj.get( "openness_intellect" )%>", "<%=( String )obj.get( "openness_authority_challenging" )%>",
    	"<%=( String )obj.get( "conscientiousness_achievement_striving" )%>", "<%=( String )obj.get( "conscientiousness_cautiousness" )%>", "<%=( String )obj.get( "conscientiousness_dutifulness" )%>", "<%=( String )obj.get( "conscientiousness_orderliness" )%>", "<%=( String )obj.get( "conscientiousness_self_discipline" )%>", "<%=( String )obj.get( "conscientiousness_self_efficacy" )%>",
    	"<%=( String )obj.get( "extraversion_activity_level" )%>", "<%=( String )obj.get( "extraversion_assertiveness" )%>", "<%=( String )obj.get( "extraversion_cheerfulness" )%>", "<%=( String )obj.get( "extraversion_excitement_seeking" )%>", "<%=( String )obj.get( "extraversion_outgoing" )%>", "<%=( String )obj.get( "extraversion_gregariousness" )%>",
    	"<%=( String )obj.get( "agreeableness_altruism" )%>", "<%=( String )obj.get( "agreeableness_cooperation" )%>", "<%=( String )obj.get( "agreeableness_modesty" )%>", "<%=( String )obj.get( "agreeableness_uncompromising" )%>", "<%=( String )obj.get( "agreeableness_sympathy" )%>", "<%=( String )obj.get( "agreeableness_trust" )%>",
		"<%=( String )obj.get( "emotional_range_fiery" )%>", "<%=( String )obj.get( "emotional_range_prone_to_worry" )%>", "<%=( String )obj.get( "emotional_range_melancholy" )%>", "<%=( String )obj.get( "emotional_range_immoderation" )%>", "<%=( String )obj.get( "emotional_range_self_consciousness" )%>", "<%=( String )obj.get( "emotional_range_susceptible_to_stress" )%>"
    ],
    datasets: [
        {
            label: "<%=me.getName()%>",
            backgroundColor: "rgba(99,132,255,0.2)",
            borderColor: "rgba(99,132,255,1)",
            pointBackgroundColor: "rgba(99,132,255,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(99,132,255,1)",
            data: [
            	<%=me.getOpenness_adventurousness()%>, <%=me.getOpenness_artistic_interests()%>, <%=me.getOpenness_emotionality()%>, <%=me.getOpenness_imagination()%>, <%=me.getOpenness_intellect()%>, <%=me.getOpenness_authority_challenging()%>,
            	<%=me.getConscientiousness_achievement_striving()%>, <%=me.getConscientiousness_cautiousness()%>, <%=me.getConscientiousness_dutifulness()%>, <%=me.getConscientiousness_orderliness()%>, <%=me.getConscientiousness_self_discipline()%>, <%=me.getConscientiousness_self_efficacy()%>,
            	<%=me.getExtraversion_activity_level()%>, <%=me.getExtraversion_assertiveness()%>, <%=me.getExtraversion_cheerfulness()%>, <%=me.getExtraversion_excitement_seeking()%>, <%=me.getExtraversion_outgoing()%>, <%=me.getExtraversion_gregariousness()%>,
            	<%=me.getAgreeableness_altruism()%>, <%=me.getAgreeableness_cooperation()%>, <%=me.getAgreeableness_modesty()%>, <%=me.getAgreeableness_uncompromising()%>, <%=me.getAgreeableness_sympathy()%>, <%=me.getAgreeableness_trust()%>,
            	<%=me.getEmotional_range_fiery()%>, <%=me.getEmotional_range_prone_to_worry()%>, <%=me.getEmotional_range_melancholy()%>, <%=me.getEmotional_range_immoderation()%>, <%=me.getEmotional_range_self_consciousness()%>, <%=me.getEmotional_range_susceptible_to_stress()%>
            ]
        },
        {
            label: "<%=top_user0.getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [
            	<%=top_user0.getOpenness_adventurousness()%>, <%=top_user0.getOpenness_artistic_interests()%>, <%=top_user0.getOpenness_emotionality()%>, <%=top_user0.getOpenness_imagination()%>, <%=top_user0.getOpenness_intellect()%>, <%=top_user0.getOpenness_authority_challenging()%>,
            	<%=top_user0.getConscientiousness_achievement_striving()%>, <%=top_user0.getConscientiousness_cautiousness()%>, <%=top_user0.getConscientiousness_dutifulness()%>, <%=top_user0.getConscientiousness_orderliness()%>, <%=top_user0.getConscientiousness_self_discipline()%>, <%=top_user0.getConscientiousness_self_efficacy()%>,
            	<%=top_user0.getExtraversion_activity_level()%>, <%=top_user0.getExtraversion_assertiveness()%>, <%=top_user0.getExtraversion_cheerfulness()%>, <%=top_user0.getExtraversion_excitement_seeking()%>, <%=top_user0.getExtraversion_outgoing()%>, <%=top_user0.getExtraversion_gregariousness()%>,
	            <%=top_user0.getAgreeableness_altruism()%>, <%=top_user0.getAgreeableness_cooperation()%>, <%=top_user0.getAgreeableness_modesty()%>, <%=top_user0.getAgreeableness_uncompromising()%>, <%=top_user0.getAgreeableness_sympathy()%>, <%=top_user0.getAgreeableness_trust()%>,
            	<%=top_user0.getEmotional_range_fiery()%>, <%=top_user0.getEmotional_range_prone_to_worry()%>, <%=top_user0.getEmotional_range_melancholy()%>, <%=top_user0.getEmotional_range_immoderation()%>, <%=top_user0.getEmotional_range_self_consciousness()%>, <%=top_user0.getEmotional_range_susceptible_to_stress()%>
            ]
        }
    ]
  };
  var options = {};
  var myRadarChart = new Chart(ctx, {
    type: 'radar',
    data: data,
    options: options
  });
});
</script>
<!-- </div> -->


<%
	me.juge.wpidemo.User user00 = app.getUser( me.getOpenness_tw_id0() );
%>
<div><a href="javascript:void(0)" id="category_openness0" onclick="show_layer('openness0');">
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと <%=( String )obj.get( "openness" )%> が近いのは <%=user00.getName()%><img src="<%=app.getProfileImageURL( user00.getTw_id() )%>" width="24" height="24" title="<%=user00.getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=user00.getTw_id()%>">&gt;&gt;</a></div>

<div id="layer_openness0" style="display:none; position:relative;" class="close">
<canvas id="chart_openness0" width="400" height="400"></canvas>
<script>
$(function(){
  var ctx = $("#chart_openness0");
  var data = {
    labels: ["<%=( String )obj.get( "openness_adventurousness" )%>", "<%=( String )obj.get( "openness_artistic_interests" )%>", "<%=( String )obj.get( "openness_emotionality" )%>", "<%=( String )obj.get( "openness_imagination" )%>", "<%=( String )obj.get( "openness_intellect" )%>", "<%=( String )obj.get( "openness_authority_challenging" )%>"],
    datasets: [
        {
            label: "<%=me.getName()%>",
            backgroundColor: "rgba(99,132,255,0.2)",
            borderColor: "rgba(99,132,255,1)",
            pointBackgroundColor: "rgba(99,132,255,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(99,132,255,1)",
            data: [<%=me.getOpenness_adventurousness()%>, <%=me.getOpenness_artistic_interests()%>, <%=me.getOpenness_emotionality()%>, <%=me.getOpenness_imagination()%>, <%=me.getOpenness_intellect()%>, <%=me.getOpenness_authority_challenging()%>]
        },
        {
            label: "<%=user00.getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=user00.getOpenness_adventurousness()%>, <%=user00.getOpenness_artistic_interests()%>, <%=user00.getOpenness_emotionality()%>, <%=user00.getOpenness_imagination()%>, <%=user00.getOpenness_intellect()%>, <%=user00.getOpenness_authority_challenging()%>]
        }
    ]
  };
  var options = {};
  var myRadarChart = new Chart(ctx, {
    type: 'radar',
    data: data,
    options: options
  });
});
</script>
</div>

<%
	me.juge.wpidemo.User user01 = app.getUser( me.getConscientiousness_tw_id0() );
%>
<div><a href="javascript:void(0)" id="category_conscientiousness0" onclick="show_layer('conscientiousness0');">
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと <%=( String )obj.get( "conscientiousness" )%> が近いのは <%=user01.getName()%><img src="<%=app.getProfileImageURL( user01.getTw_id() )%>" width="24" height="24" title="<%=user01.getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=user01.getTw_id()%>">&gt;&gt;</a></div>

<div id="layer_conscientiousness0" style="display:none; position:relative;" class="close">
<canvas id="chart_conscientiousness0" width="400" height="400"></canvas>
<script>
$(function(){
  var ctx = $("#chart_conscientiousness0");
  var data = {
    labels: ["<%=( String )obj.get( "conscientiousness_achievement_striving" )%>", "<%=( String )obj.get( "conscientiousness_cautiousness" )%>", "<%=( String )obj.get( "conscientiousness_dutifulness" )%>", "<%=( String )obj.get( "conscientiousness_orderliness" )%>", "<%=( String )obj.get( "conscientiousness_self_discipline" )%>", "<%=( String )obj.get( "conscientiousness_self_efficacy" )%>"],
    datasets: [
        {
            label: "<%=me.getName()%>",
            backgroundColor: "rgba(99,132,255,0.2)",
            borderColor: "rgba(99,132,255,1)",
            pointBackgroundColor: "rgba(99,132,255,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(99,132,255,1)",
            data: [<%=me.getConscientiousness_achievement_striving()%>, <%=me.getConscientiousness_cautiousness()%>, <%=me.getConscientiousness_dutifulness()%>, <%=me.getConscientiousness_orderliness()%>, <%=me.getConscientiousness_self_discipline()%>, <%=me.getConscientiousness_self_efficacy()%>]
        },
        {
            label: "<%=user01.getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=user01.getConscientiousness_achievement_striving()%>, <%=user01.getConscientiousness_cautiousness()%>, <%=user01.getConscientiousness_dutifulness()%>, <%=user01.getConscientiousness_orderliness()%>, <%=user01.getConscientiousness_self_discipline()%>, <%=user01.getConscientiousness_self_efficacy()%>]
        }
    ]
  };
  var options = {};
  var myRadarChart = new Chart(ctx, {
    type: 'radar',
    data: data,
    options: options
  });
});
</script>
</div>

<%
	me.juge.wpidemo.User user02 = app.getUser( me.getExtraversion_tw_id0() );
%>
<div><a href="javascript:void(0)" id="category_extraversion0" onclick="show_layer('extraversion0');">
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと <%=( String )obj.get( "extraversion" )%> が近いのは <%=user02.getName()%><img src="<%=app.getProfileImageURL( user02.getTw_id() )%>" width="24" height="24" title="<%=user02.getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=user02.getTw_id()%>">&gt;&gt;</a></div>

<div id="layer_extraversion0" style="display:none; position:relative;" class="close">
<canvas id="chart_extraversion0" width="400" height="400"></canvas>
<script>
$(function(){
  var ctx = $("#chart_extraversion0");
  var data = {
    labels: ["<%=( String )obj.get( "extraversion_activity_level" )%>", "<%=( String )obj.get( "extraversion_assertiveness" )%>", "<%=( String )obj.get( "extraversion_cheerfulness" )%>", "<%=( String )obj.get( "extraversion_excitement_seeking" )%>", "<%=( String )obj.get( "extraversion_outgoing" )%>", "<%=( String )obj.get( "extraversion_gregariousness" )%>"],
    datasets: [
        {
            label: "<%=me.getName()%>",
            backgroundColor: "rgba(99,132,255,0.2)",
            borderColor: "rgba(99,132,255,1)",
            pointBackgroundColor: "rgba(99,132,255,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(99,132,255,1)",
            data: [<%=me.getExtraversion_activity_level()%>, <%=me.getExtraversion_assertiveness()%>, <%=me.getExtraversion_cheerfulness()%>, <%=me.getExtraversion_excitement_seeking()%>, <%=me.getExtraversion_outgoing()%>, <%=me.getExtraversion_gregariousness()%>]
        },
        {
            label: "<%=user02.getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=user02.getExtraversion_activity_level()%>, <%=user02.getExtraversion_assertiveness()%>, <%=user02.getExtraversion_cheerfulness()%>, <%=user02.getExtraversion_excitement_seeking()%>, <%=user02.getExtraversion_outgoing()%>, <%=user02.getExtraversion_gregariousness()%>]
        }
    ]
  };
  var options = {};
  var myRadarChart = new Chart(ctx, {
    type: 'radar',
    data: data,
    options: options
  });
});
</script>
</div>

<%
	me.juge.wpidemo.User user03 = app.getUser( me.getAgreeableness_tw_id0() );
%>
<div><a href="javascript:void(0)" id="category_agreeableness0" onclick="show_layer('agreeableness0');">
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと <%=( String )obj.get( "agreeableness" )%> が近いのは <%=user03.getName()%><img src="<%=app.getProfileImageURL( user03.getTw_id() )%>" width="24" height="24" title="<%=user03.getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=user03.getTw_id()%>">&gt;&gt;</a></div>

<div id="layer_agreeableness0" style="display:none; position:relative;" class="close">
<canvas id="chart_agreeableness0" width="400" height="400"></canvas>
<script>
$(function(){
  var ctx = $("#chart_agreeableness0");
  var data = {
    labels: ["<%=( String )obj.get( "agreeableness_altruism" )%>", "<%=( String )obj.get( "agreeableness_cooperation" )%>", "<%=( String )obj.get( "agreeableness_modesty" )%>", "<%=( String )obj.get( "agreeableness_uncompromising" )%>", "<%=( String )obj.get( "agreeableness_sympathy" )%>", "<%=( String )obj.get( "agreeableness_trust" )%>"],
    datasets: [
        {
            label: "<%=me.getName()%>",
            backgroundColor: "rgba(99,132,255,0.2)",
            borderColor: "rgba(99,132,255,1)",
            pointBackgroundColor: "rgba(99,132,255,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(99,132,255,1)",
            data: [<%=me.getAgreeableness_altruism()%>, <%=me.getAgreeableness_cooperation()%>, <%=me.getAgreeableness_modesty()%>, <%=me.getAgreeableness_uncompromising()%>, <%=me.getAgreeableness_sympathy()%>, <%=me.getAgreeableness_trust()%>]
        },
        {
            label: "<%=user03.getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=user03.getAgreeableness_altruism()%>, <%=user03.getAgreeableness_cooperation()%>, <%=user03.getAgreeableness_modesty()%>, <%=user03.getAgreeableness_uncompromising()%>, <%=user03.getAgreeableness_sympathy()%>, <%=user03.getAgreeableness_trust()%>]
        }
    ]
  };
  var options = {};
  var myRadarChart = new Chart(ctx, {
    type: 'radar',
    data: data,
    options: options
  });
});
</script>
</div>

<%
	me.juge.wpidemo.User user04 = app.getUser( me.getEmotional_range_tw_id0() );
%>
<div><a href="javascript:void(0)" id="category_emotional_range0" onclick="show_layer('emotional_range0');">
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと <%=( String )obj.get( "emotional_range" )%> が近いのは <%=user04.getName()%><img src="<%=app.getProfileImageURL( user04.getTw_id() )%>" width="24" height="24" title="<%=user04.getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=user04.getTw_id()%>">&gt;&gt;</a></div>

<div id="layer_emotional_range0" style="display:none; position:relative;" class="close">
<canvas id="chart_emotional_range0" width="400" height="400"></canvas>
<script>
$(function(){
  var ctx = $("#chart_emotional_range0");
  var data = {
    labels: ["<%=( String )obj.get( "emotional_range_fiery" )%>", "<%=( String )obj.get( "emotional_range_prone_to_worry" )%>", "<%=( String )obj.get( "emotional_range_melancholy" )%>", "<%=( String )obj.get( "emotional_range_immoderation" )%>", "<%=( String )obj.get( "emotional_range_self_consciousness" )%>", "<%=( String )obj.get( "emotional_range_susceptible_to_stress" )%>"],
    datasets: [
        {
            label: "<%=me.getName()%>",
            backgroundColor: "rgba(99,132,255,0.2)",
            borderColor: "rgba(99,132,255,1)",
            pointBackgroundColor: "rgba(99,132,255,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(99,132,255,1)",
            data: [<%=me.getEmotional_range_fiery()%>, <%=me.getEmotional_range_prone_to_worry()%>, <%=me.getEmotional_range_melancholy()%>, <%=me.getEmotional_range_immoderation()%>, <%=me.getEmotional_range_self_consciousness()%>, <%=me.getEmotional_range_susceptible_to_stress()%>]
        },
        {
            label: "<%=user04.getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=user04.getEmotional_range_fiery()%>, <%=user04.getEmotional_range_prone_to_worry()%>, <%=user04.getEmotional_range_melancholy()%>, <%=user04.getEmotional_range_immoderation()%>, <%=user04.getEmotional_range_self_consciousness()%>, <%=user04.getEmotional_range_susceptible_to_stress()%>]
        }
    ]
  };
  var options = {};
  var myRadarChart = new Chart(ctx, {
    type: 'radar',
    data: data,
    options: options
  });
});
</script>
</div>

</div> <!-- top0 -->

<hr/>

<%
	me.juge.wpidemo.User top_user1 = app.getUser( me.getTop_tw_id1() );
%>
<div style="font-size: 16px"><a href="javascript:void(0)" id="category_top1" onclick="show_layer('top1');">
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと性格が遠いのは <%=top_user1.getName()%><img src="<%=app.getProfileImageURL( top_user1.getTw_id() )%>" width="24" height="24" title="<%=top_user1.getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=top_user1.getTw_id()%>">&gt;&gt;</a></div>

<div id="layer_top1" style="display:none; position:relative;" class="close">
<canvas id="chart_top1" width="400" height="400"></canvas>
<script>
$(function(){
  var ctx = $("#chart_top1");
  var data = {
    labels: [
    	"<%=( String )obj.get( "openness_adventurousness" )%>", "<%=( String )obj.get( "openness_artistic_interests" )%>", "<%=( String )obj.get( "openness_emotionality" )%>", "<%=( String )obj.get( "openness_imagination" )%>", "<%=( String )obj.get( "openness_intellect" )%>", "<%=( String )obj.get( "openness_authority_challenging" )%>",
    	"<%=( String )obj.get( "conscientiousness_achievement_striving" )%>", "<%=( String )obj.get( "conscientiousness_cautiousness" )%>", "<%=( String )obj.get( "conscientiousness_dutifulness" )%>", "<%=( String )obj.get( "conscientiousness_orderliness" )%>", "<%=( String )obj.get( "conscientiousness_self_discipline" )%>", "<%=( String )obj.get( "conscientiousness_self_efficacy" )%>",
    	"<%=( String )obj.get( "extraversion_activity_level" )%>", "<%=( String )obj.get( "extraversion_assertiveness" )%>", "<%=( String )obj.get( "extraversion_cheerfulness" )%>", "<%=( String )obj.get( "extraversion_excitement_seeking" )%>", "<%=( String )obj.get( "extraversion_outgoing" )%>", "<%=( String )obj.get( "extraversion_gregariousness" )%>",
    	"<%=( String )obj.get( "agreeableness_altruism" )%>", "<%=( String )obj.get( "agreeableness_cooperation" )%>", "<%=( String )obj.get( "agreeableness_modesty" )%>", "<%=( String )obj.get( "agreeableness_uncompromising" )%>", "<%=( String )obj.get( "agreeableness_sympathy" )%>", "<%=( String )obj.get( "agreeableness_trust" )%>",
		"<%=( String )obj.get( "emotional_range_fiery" )%>", "<%=( String )obj.get( "emotional_range_prone_to_worry" )%>", "<%=( String )obj.get( "emotional_range_melancholy" )%>", "<%=( String )obj.get( "emotional_range_immoderation" )%>", "<%=( String )obj.get( "emotional_range_self_consciousness" )%>", "<%=( String )obj.get( "emotional_range_susceptible_to_stress" )%>"
    ],
    datasets: [
        {
            label: "<%=me.getName()%>",
            backgroundColor: "rgba(99,132,255,0.2)",
            borderColor: "rgba(99,132,255,1)",
            pointBackgroundColor: "rgba(99,132,255,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(99,132,255,1)",
            data: [
            	<%=me.getOpenness_adventurousness()%>, <%=me.getOpenness_artistic_interests()%>, <%=me.getOpenness_emotionality()%>, <%=me.getOpenness_imagination()%>, <%=me.getOpenness_intellect()%>, <%=me.getOpenness_authority_challenging()%>,
            	<%=me.getConscientiousness_achievement_striving()%>, <%=me.getConscientiousness_cautiousness()%>, <%=me.getConscientiousness_dutifulness()%>, <%=me.getConscientiousness_orderliness()%>, <%=me.getConscientiousness_self_discipline()%>, <%=me.getConscientiousness_self_efficacy()%>,
            	<%=me.getExtraversion_activity_level()%>, <%=me.getExtraversion_assertiveness()%>, <%=me.getExtraversion_cheerfulness()%>, <%=me.getExtraversion_excitement_seeking()%>, <%=me.getExtraversion_outgoing()%>, <%=me.getExtraversion_gregariousness()%>,
            	<%=me.getAgreeableness_altruism()%>, <%=me.getAgreeableness_cooperation()%>, <%=me.getAgreeableness_modesty()%>, <%=me.getAgreeableness_uncompromising()%>, <%=me.getAgreeableness_sympathy()%>, <%=me.getAgreeableness_trust()%>,
            	<%=me.getEmotional_range_fiery()%>, <%=me.getEmotional_range_prone_to_worry()%>, <%=me.getEmotional_range_melancholy()%>, <%=me.getEmotional_range_immoderation()%>, <%=me.getEmotional_range_self_consciousness()%>, <%=me.getEmotional_range_susceptible_to_stress()%>
            ]
        },
        {
            label: "<%=top_user1.getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [
            	<%=top_user1.getOpenness_adventurousness()%>, <%=top_user1.getOpenness_artistic_interests()%>, <%=top_user1.getOpenness_emotionality()%>, <%=top_user1.getOpenness_imagination()%>, <%=top_user1.getOpenness_intellect()%>, <%=top_user1.getOpenness_authority_challenging()%>,
            	<%=top_user1.getConscientiousness_achievement_striving()%>, <%=top_user1.getConscientiousness_cautiousness()%>, <%=top_user1.getConscientiousness_dutifulness()%>, <%=top_user1.getConscientiousness_orderliness()%>, <%=top_user1.getConscientiousness_self_discipline()%>, <%=top_user1.getConscientiousness_self_efficacy()%>,
            	<%=top_user1.getExtraversion_activity_level()%>, <%=top_user1.getExtraversion_assertiveness()%>, <%=top_user1.getExtraversion_cheerfulness()%>, <%=top_user1.getExtraversion_excitement_seeking()%>, <%=top_user1.getExtraversion_outgoing()%>, <%=top_user1.getExtraversion_gregariousness()%>,
	            <%=top_user1.getAgreeableness_altruism()%>, <%=top_user1.getAgreeableness_cooperation()%>, <%=top_user1.getAgreeableness_modesty()%>, <%=top_user1.getAgreeableness_uncompromising()%>, <%=top_user1.getAgreeableness_sympathy()%>, <%=top_user1.getAgreeableness_trust()%>,
            	<%=top_user1.getEmotional_range_fiery()%>, <%=top_user1.getEmotional_range_prone_to_worry()%>, <%=top_user1.getEmotional_range_melancholy()%>, <%=top_user1.getEmotional_range_immoderation()%>, <%=top_user1.getEmotional_range_self_consciousness()%>, <%=top_user1.getEmotional_range_susceptible_to_stress()%>
            ]
        }
    ]
  };
  var options = {};
  var myRadarChart = new Chart(ctx, {
    type: 'radar',
    data: data,
    options: options
  });
});
</script>
<!-- </div> -->


<%
	me.juge.wpidemo.User user10 = app.getUser( me.getOpenness_tw_id1() );
%>
<div><a href="javascript:void(0)" id="category_openness1" onclick="show_layer('openness1');">
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと <%=( String )obj.get( "openness" )%> が遠いのは <%=user10.getName()%><img src="<%=app.getProfileImageURL( user10.getTw_id() )%>" width="24" height="24" title="<%=user10.getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=user10.getTw_id()%>">&gt;&gt;</a></div>

<div id="layer_openness1" style="display:none; position:relative;" class="close">
<canvas id="chart_openness1" width="400" height="400"></canvas>
<script>
$(function(){
  var ctx = $("#chart_openness1");
  var data = {
    labels: ["<%=( String )obj.get( "openness_adventurousness" )%>", "<%=( String )obj.get( "openness_artistic_interests" )%>", "<%=( String )obj.get( "openness_emotionality" )%>", "<%=( String )obj.get( "openness_imagination" )%>", "<%=( String )obj.get( "openness_intellect" )%>", "<%=( String )obj.get( "openness_authority_challenging" )%>"],
    datasets: [
        {
            label: "<%=me.getName()%>",
            backgroundColor: "rgba(99,132,255,0.2)",
            borderColor: "rgba(99,132,255,1)",
            pointBackgroundColor: "rgba(99,132,255,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(99,132,255,1)",
            data: [<%=me.getOpenness_adventurousness()%>, <%=me.getOpenness_artistic_interests()%>, <%=me.getOpenness_emotionality()%>, <%=me.getOpenness_imagination()%>, <%=me.getOpenness_intellect()%>, <%=me.getOpenness_authority_challenging()%>]
        },
        {
            label: "<%=user10.getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=user10.getOpenness_adventurousness()%>, <%=user10.getOpenness_artistic_interests()%>, <%=user10.getOpenness_emotionality()%>, <%=user10.getOpenness_imagination()%>, <%=user10.getOpenness_intellect()%>, <%=user10.getOpenness_authority_challenging()%>]
        }
    ]
  };
  var options = {};
  var myRadarChart = new Chart(ctx, {
    type: 'radar',
    data: data,
    options: options
  });
});
</script>
</div>

<%
	me.juge.wpidemo.User user11 = app.getUser( me.getConscientiousness_tw_id1() );
%>
<div><a href="javascript:void(0)" id="category_conscientiousness1" onclick="show_layer('conscientiousness1');">
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと <%=( String )obj.get( "conscientiousness" )%> が遠いのは <%=user11.getName()%><img src="<%=app.getProfileImageURL( user11.getTw_id() )%>" width="24" height="24" title="<%=user11.getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=user11.getTw_id()%>">&gt;&gt;</a></div>

<div id="layer_conscientiousness1" style="display:none; position:relative;" class="close">
<canvas id="chart_conscientiousness1" width="400" height="400"></canvas>
<script>
$(function(){
  var ctx = $("#chart_conscientiousness1");
  var data = {
    labels: ["<%=( String )obj.get( "conscientiousness_achievement_striving" )%>", "<%=( String )obj.get( "conscientiousness_cautiousness" )%>", "<%=( String )obj.get( "conscientiousness_dutifulness" )%>", "<%=( String )obj.get( "conscientiousness_orderliness" )%>", "<%=( String )obj.get( "conscientiousness_self_discipline" )%>", "<%=( String )obj.get( "conscientiousness_self_efficacy" )%>"],
    datasets: [
        {
            label: "<%=me.getName()%>",
            backgroundColor: "rgba(99,132,255,0.2)",
            borderColor: "rgba(99,132,255,1)",
            pointBackgroundColor: "rgba(99,132,255,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(99,132,255,1)",
            data: [<%=me.getConscientiousness_achievement_striving()%>, <%=me.getConscientiousness_cautiousness()%>, <%=me.getConscientiousness_dutifulness()%>, <%=me.getConscientiousness_orderliness()%>, <%=me.getConscientiousness_self_discipline()%>, <%=me.getConscientiousness_self_efficacy()%>]
        },
        {
            label: "<%=user11.getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=user11.getConscientiousness_achievement_striving()%>, <%=user11.getConscientiousness_cautiousness()%>, <%=user11.getConscientiousness_dutifulness()%>, <%=user11.getConscientiousness_orderliness()%>, <%=user11.getConscientiousness_self_discipline()%>, <%=user11.getConscientiousness_self_efficacy()%>]
        }
    ]
  };
  var options = {};
  var myRadarChart = new Chart(ctx, {
    type: 'radar',
    data: data,
    options: options
  });
});
</script>
</div>

<%
	me.juge.wpidemo.User user12 = app.getUser( me.getExtraversion_tw_id1() );
%>
<div><a href="javascript:void(0)" id="category_extraversion1" onclick="show_layer('extraversion1');">
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと <%=( String )obj.get( "extraversion" )%> が遠いのは <%=user12.getName()%><img src="<%=app.getProfileImageURL( user12.getTw_id() )%>" width="24" height="24" title="<%=user12.getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=user12.getTw_id()%>">&gt;&gt;</a></div>

<div id="layer_extraversion1" style="display:none; position:relative;" class="close">
<canvas id="chart_extraversion1" width="400" height="400"></canvas>
<script>
$(function(){
  var ctx = $("#chart_extraversion1");
  var data = {
    labels: ["<%=( String )obj.get( "extraversion_activity_level" )%>", "<%=( String )obj.get( "extraversion_assertiveness" )%>", "<%=( String )obj.get( "extraversion_cheerfulness" )%>", "<%=( String )obj.get( "extraversion_excitement_seeking" )%>", "<%=( String )obj.get( "extraversion_outgoing" )%>", "<%=( String )obj.get( "extraversion_gregariousness" )%>"],
    datasets: [
        {
            label: "<%=me.getName()%>",
            backgroundColor: "rgba(99,132,255,0.2)",
            borderColor: "rgba(99,132,255,1)",
            pointBackgroundColor: "rgba(99,132,255,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(99,132,255,1)",
            data: [<%=me.getExtraversion_activity_level()%>, <%=me.getExtraversion_assertiveness()%>, <%=me.getExtraversion_cheerfulness()%>, <%=me.getExtraversion_excitement_seeking()%>, <%=me.getExtraversion_outgoing()%>, <%=me.getExtraversion_gregariousness()%>]
        },
        {
            label: "<%=user12.getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=user12.getExtraversion_activity_level()%>, <%=user12.getExtraversion_assertiveness()%>, <%=user12.getExtraversion_cheerfulness()%>, <%=user12.getExtraversion_excitement_seeking()%>, <%=user12.getExtraversion_outgoing()%>, <%=user12.getExtraversion_gregariousness()%>]
        }
    ]
  };
  var options = {};
  var myRadarChart = new Chart(ctx, {
    type: 'radar',
    data: data,
    options: options
  });
});
</script>
</div>

<%
	me.juge.wpidemo.User user13 = app.getUser( me.getAgreeableness_tw_id1() );
%>
<div><a href="javascript:void(0)" id="category_agreeableness1" onclick="show_layer('agreeableness1');">
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと <%=( String )obj.get( "agreeableness" )%> が遠いのは <%=user13.getName()%><img src="<%=app.getProfileImageURL( user13.getTw_id() )%>" width="24" height="24" title="<%=user13.getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=user13.getTw_id()%>">&gt;&gt;</a></div>

<div id="layer_agreeableness1" style="display:none; position:relative;" class="close">
<canvas id="chart_agreeableness1" width="400" height="400"></canvas>
<script>
$(function(){
  var ctx = $("#chart_agreeableness1");
  var data = {
    labels: ["<%=( String )obj.get( "agreeableness_altruism" )%>", "<%=( String )obj.get( "agreeableness_cooperation" )%>", "<%=( String )obj.get( "agreeableness_modesty" )%>", "<%=( String )obj.get( "agreeableness_uncompromising" )%>", "<%=( String )obj.get( "agreeableness_sympathy" )%>", "<%=( String )obj.get( "agreeableness_trust" )%>"],
    datasets: [
        {
            label: "<%=me.getName()%>",
            backgroundColor: "rgba(99,132,255,0.2)",
            borderColor: "rgba(99,132,255,1)",
            pointBackgroundColor: "rgba(99,132,255,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(99,132,255,1)",
            data: [<%=me.getAgreeableness_altruism()%>, <%=me.getAgreeableness_cooperation()%>, <%=me.getAgreeableness_modesty()%>, <%=me.getAgreeableness_uncompromising()%>, <%=me.getAgreeableness_sympathy()%>, <%=me.getAgreeableness_trust()%>]
        },
        {
            label: "<%=user13.getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=user13.getAgreeableness_altruism()%>, <%=user13.getAgreeableness_cooperation()%>, <%=user13.getAgreeableness_modesty()%>, <%=user13.getAgreeableness_uncompromising()%>, <%=user13.getAgreeableness_sympathy()%>, <%=user13.getAgreeableness_trust()%>]
        }
    ]
  };
  var options = {};
  var myRadarChart = new Chart(ctx, {
    type: 'radar',
    data: data,
    options: options
  });
});
</script>
</div>

<%
	me.juge.wpidemo.User user14 = app.getUser( me.getEmotional_range_tw_id1() );
%>
<div><a href="javascript:void(0)" id="category_emotional_range1" onclick="show_layer('emotional_range1');">
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと <%=( String )obj.get( "emotional_range" )%> が遠いのは <%=user14.getName()%><img src="<%=app.getProfileImageURL( user14.getTw_id() )%>" width="24" height="24" title="<%=user14.getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=user14.getTw_id()%>">&gt;&gt;</a></div>

<div id="layer_emotional_range1" style="display:none; position:relative;" class="close">
<canvas id="chart_emotional_range1" width="400" height="400"></canvas>
<script>
$(function(){
  var ctx = $("#chart_emotional_range1");
  var data = {
    labels: ["<%=( String )obj.get( "emotional_range_fiery" )%>", "<%=( String )obj.get( "emotional_range_prone_to_worry" )%>", "<%=( String )obj.get( "emotional_range_melancholy" )%>", "<%=( String )obj.get( "emotional_range_immoderation" )%>", "<%=( String )obj.get( "emotional_range_self_consciousness" )%>", "<%=( String )obj.get( "emotional_range_susceptible_to_stress" )%>"],
    datasets: [
        {
            label: "<%=me.getName()%>",
            backgroundColor: "rgba(99,132,255,0.2)",
            borderColor: "rgba(99,132,255,1)",
            pointBackgroundColor: "rgba(99,132,255,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(99,132,255,1)",
            data: [<%=me.getEmotional_range_fiery()%>, <%=me.getEmotional_range_prone_to_worry()%>, <%=me.getEmotional_range_melancholy()%>, <%=me.getEmotional_range_immoderation()%>, <%=me.getEmotional_range_self_consciousness()%>, <%=me.getEmotional_range_susceptible_to_stress()%>]
        },
        {
            label: "<%=user14.getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=user14.getEmotional_range_fiery()%>, <%=user14.getEmotional_range_prone_to_worry()%>, <%=user14.getEmotional_range_melancholy()%>, <%=user14.getEmotional_range_immoderation()%>, <%=user14.getEmotional_range_self_consciousness()%>, <%=user14.getEmotional_range_susceptible_to_stress()%>]
        }
    ]
  };
  var options = {};
  var myRadarChart = new Chart(ctx, {
    type: 'radar',
    data: data,
    options: options
  });
});
</script>
</div>

</div> <!-- top1 -->

</div>

<div class="container" align="middle" style="padding:20px 0">
<a href="<%=authorizationURL%>" class="btn btn-success active">自分もやってみる</a>
</div>

<%
	}else{
	//. me == null
%>
<title>エラー</title>
</head>
<body>
<%
	}
%>

<p/>

<jsp:include page="foot.jsp">
  <jsp:param name="page" value="result"/>
</jsp:include>

</body>
</html>

