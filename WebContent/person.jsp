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
<meta property="og:description" content="自分でも気付かない性格をあなたがツイートした内容から判断します。また同じような性格のAKBメンバーや、全く異なる性格を持つAKBメンバーを探しだしてくれるサービスです。"/>
<!-- og tags// -->

<meta name="description" content="自分でも気付かない性格をあなたがツイートした内容から判断します。また同じような性格のAKBメンバーや、全く異なる性格を持つAKBメンバーを探しだしてくれるサービスです。"/>
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
me.juge.wpidemo.User user = null;
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

String personname = "";
if( id != null && id.length() > 0 ){
	user = app.getUser( id );
	if( user != null ){
		personname = user.getName();
	}
}
%>
<title><%=personname%>さんの性格</title>
</head>
<body>

<nav class="navbar navbar-default">
 <div class="container-fluid">
  <div class="navbar-header">
   <a class="navbar-brand" href="./"><%=personname%>さんの性格</a>
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
	RequestToken requestToken = twitter.getOAuthRequestToken( "http://akb-finder.mybluemix.net/" );

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
 	if( user != null ){
 %>
<div class="container" style="padding:20px 0">


<div style="font-size: 16px"><a href="javascript:void(0)" id="category_top0" onclick="show_layer('top0');">
<%=user.getName()%><img src="<%=app.getProfileImageURL( user.getTw_id() )%>" width="24" height="24" title="<%=user.getTw_id()%>"/>さんの性格
</a> <a target="_blank" href="http://twitter.com/<%=user.getTw_id()%>">&gt;&gt;</a></div>

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
            label: "<%=user.getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [
            	<%=user.getOpenness_adventurousness()%>, <%=user.getOpenness_artistic_interests()%>, <%=user.getOpenness_emotionality()%>, <%=user.getOpenness_imagination()%>, <%=user.getOpenness_intellect()%>, <%=user.getOpenness_authority_challenging()%>,
            	<%=user.getConscientiousness_achievement_striving()%>, <%=user.getConscientiousness_cautiousness()%>, <%=user.getConscientiousness_dutifulness()%>, <%=user.getConscientiousness_orderliness()%>, <%=user.getConscientiousness_self_discipline()%>, <%=user.getConscientiousness_self_efficacy()%>,
            	<%=user.getExtraversion_activity_level()%>, <%=user.getExtraversion_assertiveness()%>, <%=user.getExtraversion_cheerfulness()%>, <%=user.getExtraversion_excitement_seeking()%>, <%=user.getExtraversion_outgoing()%>, <%=user.getExtraversion_gregariousness()%>,
	            <%=user.getAgreeableness_altruism()%>, <%=user.getAgreeableness_cooperation()%>, <%=user.getAgreeableness_modesty()%>, <%=user.getAgreeableness_uncompromising()%>, <%=user.getAgreeableness_sympathy()%>, <%=user.getAgreeableness_trust()%>,
            	<%=user.getEmotional_range_fiery()%>, <%=user.getEmotional_range_prone_to_worry()%>, <%=user.getEmotional_range_melancholy()%>, <%=user.getEmotional_range_immoderation()%>, <%=user.getEmotional_range_self_consciousness()%>, <%=user.getEmotional_range_susceptible_to_stress()%>
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

<div><a href="javascript:void(0)" id="category_openness0" onclick="show_layer('openness0');">
<%=user.getName()%><img src="<%=app.getProfileImageURL( user.getTw_id() )%>" width="24" height="24" title="<%=user.getTw_id()%>"/>さんの <%=( String )obj.get( "openness" )%> 
</a></div>

<div id="layer_openness0" style="display:none; position:relative;" class="close">
<canvas id="chart_openness0" width="400" height="400"></canvas>
<script>
$(function(){
  var ctx = $("#chart_openness0");
  var data = {
    labels: ["<%=( String )obj.get( "openness_adventurousness" )%>", "<%=( String )obj.get( "openness_artistic_interests" )%>", "<%=( String )obj.get( "openness_emotionality" )%>", "<%=( String )obj.get( "openness_imagination" )%>", "<%=( String )obj.get( "openness_intellect" )%>", "<%=( String )obj.get( "openness_authority_challenging" )%>"],
    datasets: [
        {
            label: "<%=user.getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=user.getOpenness_adventurousness()%>, <%=user.getOpenness_artistic_interests()%>, <%=user.getOpenness_emotionality()%>, <%=user.getOpenness_imagination()%>, <%=user.getOpenness_intellect()%>, <%=user.getOpenness_authority_challenging()%>]
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

<div><a href="javascript:void(0)" id="category_conscientiousness0" onclick="show_layer('conscientiousness0');">
<%=user.getName()%><img src="<%=app.getProfileImageURL( user.getTw_id() )%>" width="24" height="24" title="<%=user.getTw_id()%>"/>さんの <%=( String )obj.get( "conscientiousness" )%> 
</a> </div>

<div id="layer_conscientiousness0" style="display:none; position:relative;" class="close">
<canvas id="chart_conscientiousness0" width="400" height="400"></canvas>
<script>
$(function(){
  var ctx = $("#chart_conscientiousness0");
  var data = {
    labels: ["<%=( String )obj.get( "conscientiousness_achievement_striving" )%>", "<%=( String )obj.get( "conscientiousness_cautiousness" )%>", "<%=( String )obj.get( "conscientiousness_dutifulness" )%>", "<%=( String )obj.get( "conscientiousness_orderliness" )%>", "<%=( String )obj.get( "conscientiousness_self_discipline" )%>", "<%=( String )obj.get( "conscientiousness_self_efficacy" )%>"],
    datasets: [
        {
            label: "<%=user.getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=user.getConscientiousness_achievement_striving()%>, <%=user.getConscientiousness_cautiousness()%>, <%=user.getConscientiousness_dutifulness()%>, <%=user.getConscientiousness_orderliness()%>, <%=user.getConscientiousness_self_discipline()%>, <%=user.getConscientiousness_self_efficacy()%>]
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

<div><a href="javascript:void(0)" id="category_extraversion0" onclick="show_layer('extraversion0');">
<%=user.getName()%><img src="<%=app.getProfileImageURL( user.getTw_id() )%>" width="24" height="24" title="<%=user.getTw_id()%>"/>さんの <%=( String )obj.get( "extraversion" )%> 
</a> </div>

<div id="layer_extraversion0" style="display:none; position:relative;" class="close">
<canvas id="chart_extraversion0" width="400" height="400"></canvas>
<script>
$(function(){
  var ctx = $("#chart_extraversion0");
  var data = {
    labels: ["<%=( String )obj.get( "extraversion_activity_level" )%>", "<%=( String )obj.get( "extraversion_assertiveness" )%>", "<%=( String )obj.get( "extraversion_cheerfulness" )%>", "<%=( String )obj.get( "extraversion_excitement_seeking" )%>", "<%=( String )obj.get( "extraversion_outgoing" )%>", "<%=( String )obj.get( "extraversion_gregariousness" )%>"],
    datasets: [
        {
            label: "<%=user.getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=user.getExtraversion_activity_level()%>, <%=user.getExtraversion_assertiveness()%>, <%=user.getExtraversion_cheerfulness()%>, <%=user.getExtraversion_excitement_seeking()%>, <%=user.getExtraversion_outgoing()%>, <%=user.getExtraversion_gregariousness()%>]
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

<div><a href="javascript:void(0)" id="category_agreeableness0" onclick="show_layer('agreeableness0');">
<%=user.getName()%><img src="<%=app.getProfileImageURL( user.getTw_id() )%>" width="24" height="24" title="<%=user.getTw_id()%>"/>さんの <%=( String )obj.get( "agreeableness" )%> 
</a> </div>

<div id="layer_agreeableness0" style="display:none; position:relative;" class="close">
<canvas id="chart_agreeableness0" width="400" height="400"></canvas>
<script>
$(function(){
  var ctx = $("#chart_agreeableness0");
  var data = {
    labels: ["<%=( String )obj.get( "agreeableness_altruism" )%>", "<%=( String )obj.get( "agreeableness_cooperation" )%>", "<%=( String )obj.get( "agreeableness_modesty" )%>", "<%=( String )obj.get( "agreeableness_uncompromising" )%>", "<%=( String )obj.get( "agreeableness_sympathy" )%>", "<%=( String )obj.get( "agreeableness_trust" )%>"],
    datasets: [
        {
            label: "<%=user.getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=user.getAgreeableness_altruism()%>, <%=user.getAgreeableness_cooperation()%>, <%=user.getAgreeableness_modesty()%>, <%=user.getAgreeableness_uncompromising()%>, <%=user.getAgreeableness_sympathy()%>, <%=user.getAgreeableness_trust()%>]
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

<div><a href="javascript:void(0)" id="category_emotional_range0" onclick="show_layer('emotional_range0');">
<%=user.getName()%><img src="<%=app.getProfileImageURL( user.getTw_id() )%>" width="24" height="24" title="<%=user.getTw_id()%>"/>さんの <%=( String )obj.get( "emotional_range" )%> 
</a> </div>

<div id="layer_emotional_range0" style="display:none; position:relative;" class="close">
<canvas id="chart_emotional_range0" width="400" height="400"></canvas>
<script>
$(function(){
  var ctx = $("#chart_emotional_range0");
  var data = {
    labels: ["<%=( String )obj.get( "emotional_range_fiery" )%>", "<%=( String )obj.get( "emotional_range_prone_to_worry" )%>", "<%=( String )obj.get( "emotional_range_melancholy" )%>", "<%=( String )obj.get( "emotional_range_immoderation" )%>", "<%=( String )obj.get( "emotional_range_self_consciousness" )%>", "<%=( String )obj.get( "emotional_range_susceptible_to_stress" )%>"],
    datasets: [
        {
            label: "<%=user.getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=user.getEmotional_range_fiery()%>, <%=user.getEmotional_range_prone_to_worry()%>, <%=user.getEmotional_range_melancholy()%>, <%=user.getEmotional_range_immoderation()%>, <%=user.getEmotional_range_self_consciousness()%>, <%=user.getEmotional_range_susceptible_to_stress()%>]
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

</div>

<div class="container" align="middle" style="padding:20px 0">
<a href="<%=authorizationURL%>" class="btn btn-success active">自分もやってみる</a>
</div>

<div class="container" align="middle" style="padding:20px 0">
<table border="0">
<tr>
<td>
<a target="_blank" href="http://twitter.com/share?url=http%3A%2F%2Fakb-finder.mybluemix.net%2Fperson.jsp%3Fid%3D<%=user.getTw_id()%>&text=<%= user.getName() %>さんの性格を分析してみた。。"><img src="./tw.png"/></a>
</td>
<td>
<a target="_blank" href="http://www.facebook.com/sharer.php?u=http%3A%2F%2Fakb-finder.mybluemix.net%2Fperson.jsp%3Fid%3D<%=user.getTw_id()%>&text=<%= user.getName() %>さんの性格を分析してみた。。" rel="nofollow"><img src="./fb.png"/></a>
</td>
</tr>
</table>
</div>


<%
	}else{
	//. user == null
%>
<title>エラー</title>
</head>
<body>
<%
	}
%>

<p/>

<jsp:include page="foot.jsp">
  <jsp:param name="page" value="person"/>
</jsp:include>

</body>
</html>

