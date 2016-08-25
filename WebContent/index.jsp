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
</head>
<body>

<nav class="navbar navbar-default">
 <div class="container-fluid">
  <div class="navbar-header">
   <a class="navbar-brand" href="./">自分と性格が近い／遠いAKBメンバーを調べる</a>
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
	Twitter twitter = null;
App app = new App();
String tw_id = null;
JSONObject obj = null;
int[] idx0 = new int[6], idx1 = new int[6];
boolean isError = false;

//. 自分
me.juge.wpidemo.User me = null;

//. 比較対象
me.juge.wpidemo.User[] users = app.getAllUsers();

try{
	twitter = ( Twitter )session.getAttribute( "twitter" );
}catch( Exception e ){
}

if( twitter == null ){
	try{
		String oauth_token = request.getParameter( "oauth_token" );
		if( oauth_token == null ) oauth_token = "";
		if( oauth_token.length() > 0 ){
	twitter4j.User t4j_user = ( twitter4j.User )session.getAttribute( "twitter-user" );
	if( t4j_user == null ){
		String oauth_verifier = request.getParameter( "oauth_verifier" );
		if( oauth_verifier == null ) oauth_verifier = "";
	
		twitter = new TwitterFactory().getInstance();
		twitter.setOAuthConsumer( app.tw_consumer_key, app.tw_consumer_secret );

		RequestToken tkn = new RequestToken( oauth_token, ( String )session.getAttribute( "tokenSecret" ) );
		AccessToken accessToken = twitter.getOAuthAccessToken( tkn, oauth_verifier ); //. NullPointerException
		twitter.setOAuthAccessToken( accessToken );
		session.setAttribute( "twitter", twitter );
	}
		}
	}catch( Exception e ){
	}
}	
	
if( twitter != null ){			
	twitter4j.User t4j_user = twitter.verifyCredentials();
	
	tw_id = t4j_user.getScreenName();
	me = app.getUserByTw_Id( tw_id );
	if( me != null ){
		//. カテゴリーごとに比較
		double[] min = new double[6], max = new double[6];
		for( int x = 0; x < 6; x ++ ){
	min[x] = 100000.0;
	max[x] = 0.0;
		}
		for( int i = 0; i < users.length; i ++ ){
	me.juge.wpidemo.User user = users[i];
	double[] v = app.compareByCategory( me, user );
	for( int x = 0; x < 6; x ++ ){
		if( min[x] > v[x] ){
			min[x] = v[x];
			idx0[x] = i;
		}
		if( max[x] < v[x] ){
			max[x] = v[x];
			idx1[x] = i;
		}
	}
		}
	}
		
	JSONParser parser = new JSONParser();
	try{
		obj = ( JSONObject )parser.parse( app.big5 );
	}catch( Exception e ){
		e.printStackTrace();
	}

	if( t4j_user != null ){
		session.setAttribute( "twitter-user", t4j_user );
	}
}


if( tw_id != null && tw_id.length() > 0 ){
	twitter4j.User t4j_user = ( twitter4j.User )session.getAttribute( "twitter-user" );
	String p_url = t4j_user.getProfileImageURL().toString();
%>
<a href="#" onClick="logoff();" data-role="button" rel="external"><img src="<%=p_url%>" width="20" height="20"/></a>
<%
	}else{
	String authorizationURL = null;
	try{
		twitter = new TwitterFactory().getInstance();
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
}
%>
    </li>
   </ul>
  </div>
 </div>
</nav>

<script type="text/javascript">
function logoff(){
	location.href = "./logoff";
}

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


<div style="font-size: 16px"><a href="javascript:void(0)" id="category_top0" onclick="show_layer('top0');">
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと性格が近いのは <%=users[idx0[5]].getName()%><img src="<%=app.getProfileImageURL( users[idx0[5]].getTw_id() )%>" width="24" height="24" title="<%=users[idx0[5]].getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=users[idx0[5]].getTw_id()%>">&gt;&gt;</a></div>

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
            label: "<%=users[idx0[5]].getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [
            	<%=users[idx0[5]].getOpenness_adventurousness()%>, <%=users[idx0[5]].getOpenness_artistic_interests()%>, <%=users[idx0[5]].getOpenness_emotionality()%>, <%=users[idx0[5]].getOpenness_imagination()%>, <%=users[idx0[5]].getOpenness_intellect()%>, <%=users[idx0[5]].getOpenness_authority_challenging()%>,
            	<%=users[idx0[5]].getConscientiousness_achievement_striving()%>, <%=users[idx0[5]].getConscientiousness_cautiousness()%>, <%=users[idx0[5]].getConscientiousness_dutifulness()%>, <%=users[idx0[5]].getConscientiousness_orderliness()%>, <%=users[idx0[5]].getConscientiousness_self_discipline()%>, <%=users[idx0[5]].getConscientiousness_self_efficacy()%>,
            	<%=users[idx0[5]].getExtraversion_activity_level()%>, <%=users[idx0[5]].getExtraversion_assertiveness()%>, <%=users[idx0[5]].getExtraversion_cheerfulness()%>, <%=users[idx0[5]].getExtraversion_excitement_seeking()%>, <%=users[idx0[5]].getExtraversion_outgoing()%>, <%=users[idx0[5]].getExtraversion_gregariousness()%>,
	            <%=users[idx0[5]].getAgreeableness_altruism()%>, <%=users[idx0[5]].getAgreeableness_cooperation()%>, <%=users[idx0[5]].getAgreeableness_modesty()%>, <%=users[idx0[5]].getAgreeableness_uncompromising()%>, <%=users[idx0[5]].getAgreeableness_sympathy()%>, <%=users[idx0[5]].getAgreeableness_trust()%>,
            	<%=users[idx0[5]].getEmotional_range_fiery()%>, <%=users[idx0[5]].getEmotional_range_prone_to_worry()%>, <%=users[idx0[5]].getEmotional_range_melancholy()%>, <%=users[idx0[5]].getEmotional_range_immoderation()%>, <%=users[idx0[5]].getEmotional_range_self_consciousness()%>, <%=users[idx0[5]].getEmotional_range_susceptible_to_stress()%>
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
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと <%=( String )obj.get( "openness" )%> が近いのは <%=users[idx0[0]].getName()%><img src="<%=app.getProfileImageURL( users[idx0[0]].getTw_id() )%>" width="24" height="24" title="<%=users[idx0[0]].getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=users[idx0[0]].getTw_id()%>">&gt;&gt;</a></div>

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
            label: "<%=users[idx0[0]].getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=users[idx0[0]].getOpenness_adventurousness()%>, <%=users[idx0[0]].getOpenness_artistic_interests()%>, <%=users[idx0[0]].getOpenness_emotionality()%>, <%=users[idx0[0]].getOpenness_imagination()%>, <%=users[idx0[0]].getOpenness_intellect()%>, <%=users[idx0[0]].getOpenness_authority_challenging()%>]
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
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと <%=( String )obj.get( "conscientiousness" )%> が近いのは <%=users[idx0[1]].getName()%><img src="<%=app.getProfileImageURL( users[idx0[1]].getTw_id() )%>" width="24" height="24" title="<%=users[idx0[1]].getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=users[idx0[1]].getTw_id()%>">&gt;&gt;</a></div>

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
            label: "<%=users[idx0[1]].getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=users[idx0[1]].getConscientiousness_achievement_striving()%>, <%=users[idx0[1]].getConscientiousness_cautiousness()%>, <%=users[idx0[1]].getConscientiousness_dutifulness()%>, <%=users[idx0[1]].getConscientiousness_orderliness()%>, <%=users[idx0[1]].getConscientiousness_self_discipline()%>, <%=users[idx0[1]].getConscientiousness_self_efficacy()%>]
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
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと <%=( String )obj.get( "extraversion" )%> が近いのは <%=users[idx0[2]].getName()%><img src="<%=app.getProfileImageURL( users[idx0[2]].getTw_id() )%>" width="24" height="24" title="<%=users[idx0[2]].getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=users[idx0[2]].getTw_id()%>">&gt;&gt;</a></div>

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
            label: "<%=users[idx0[2]].getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=users[idx0[2]].getExtraversion_activity_level()%>, <%=users[idx0[2]].getExtraversion_assertiveness()%>, <%=users[idx0[2]].getExtraversion_cheerfulness()%>, <%=users[idx0[2]].getExtraversion_excitement_seeking()%>, <%=users[idx0[2]].getExtraversion_outgoing()%>, <%=users[idx0[2]].getExtraversion_gregariousness()%>]
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
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと <%=( String )obj.get( "agreeableness" )%> が近いのは <%=users[idx0[3]].getName()%><img src="<%=app.getProfileImageURL( users[idx0[3]].getTw_id() )%>" width="24" height="24" title="<%=users[idx0[3]].getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=users[idx0[3]].getTw_id()%>">&gt;&gt;</a></div>

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
            label: "<%=users[idx0[3]].getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=users[idx0[3]].getAgreeableness_altruism()%>, <%=users[idx0[3]].getAgreeableness_cooperation()%>, <%=users[idx0[3]].getAgreeableness_modesty()%>, <%=users[idx0[3]].getAgreeableness_uncompromising()%>, <%=users[idx0[3]].getAgreeableness_sympathy()%>, <%=users[idx0[3]].getAgreeableness_trust()%>]
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
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと <%=( String )obj.get( "emotional_range" )%> が近いのは <%=users[idx0[4]].getName()%><img src="<%=app.getProfileImageURL( users[idx0[4]].getTw_id() )%>" width="24" height="24" title="<%=users[idx0[4]].getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=users[idx0[4]].getTw_id()%>">&gt;&gt;</a></div>

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
            label: "<%=users[idx0[4]].getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=users[idx0[4]].getEmotional_range_fiery()%>, <%=users[idx0[4]].getEmotional_range_prone_to_worry()%>, <%=users[idx0[4]].getEmotional_range_melancholy()%>, <%=users[idx0[4]].getEmotional_range_immoderation()%>, <%=users[idx0[4]].getEmotional_range_self_consciousness()%>, <%=users[idx0[4]].getEmotional_range_susceptible_to_stress()%>]
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


<div style="font-size: 16px"><a href="javascript:void(0)" id="category_top1" onclick="show_layer('top1');">
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと性格が遠いのは <%=users[idx1[5]].getName()%><img src="<%=app.getProfileImageURL( users[idx1[5]].getTw_id() )%>" width="24" height="24" title="<%=users[idx1[5]].getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=users[idx1[5]].getTw_id()%>">&gt;&gt;</a></div>

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
            label: "<%=users[idx1[5]].getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [
            	<%=users[idx1[5]].getOpenness_adventurousness()%>, <%=users[idx1[5]].getOpenness_artistic_interests()%>, <%=users[idx1[5]].getOpenness_emotionality()%>, <%=users[idx1[5]].getOpenness_imagination()%>, <%=users[idx1[5]].getOpenness_intellect()%>, <%=users[idx1[5]].getOpenness_authority_challenging()%>,
            	<%=users[idx1[5]].getConscientiousness_achievement_striving()%>, <%=users[idx1[5]].getConscientiousness_cautiousness()%>, <%=users[idx1[5]].getConscientiousness_dutifulness()%>, <%=users[idx1[5]].getConscientiousness_orderliness()%>, <%=users[idx1[5]].getConscientiousness_self_discipline()%>, <%=users[idx1[5]].getConscientiousness_self_efficacy()%>,
            	<%=users[idx1[5]].getExtraversion_activity_level()%>, <%=users[idx1[5]].getExtraversion_assertiveness()%>, <%=users[idx1[5]].getExtraversion_cheerfulness()%>, <%=users[idx1[5]].getExtraversion_excitement_seeking()%>, <%=users[idx1[5]].getExtraversion_outgoing()%>, <%=users[idx1[5]].getExtraversion_gregariousness()%>,
	            <%=users[idx1[5]].getAgreeableness_altruism()%>, <%=users[idx1[5]].getAgreeableness_cooperation()%>, <%=users[idx1[5]].getAgreeableness_modesty()%>, <%=users[idx1[5]].getAgreeableness_uncompromising()%>, <%=users[idx1[5]].getAgreeableness_sympathy()%>, <%=users[idx1[5]].getAgreeableness_trust()%>,
            	<%=users[idx1[5]].getEmotional_range_fiery()%>, <%=users[idx1[5]].getEmotional_range_prone_to_worry()%>, <%=users[idx1[5]].getEmotional_range_melancholy()%>, <%=users[idx1[5]].getEmotional_range_immoderation()%>, <%=users[idx1[5]].getEmotional_range_self_consciousness()%>, <%=users[idx1[5]].getEmotional_range_susceptible_to_stress()%>
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


<div><a href="javascript:void(0)" id="category_openness1" onclick="show_layer('openness1');">
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと <%=( String )obj.get( "openness" )%> が遠いのは <%=users[idx1[0]].getName()%><img src="<%=app.getProfileImageURL( users[idx1[0]].getTw_id() )%>" width="24" height="24" title="<%=users[idx1[0]].getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=users[idx1[0]].getTw_id()%>">&gt;&gt;</a></div>

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
            label: "<%=users[idx1[0]].getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=users[idx1[0]].getOpenness_adventurousness()%>, <%=users[idx1[0]].getOpenness_artistic_interests()%>, <%=users[idx1[0]].getOpenness_emotionality()%>, <%=users[idx1[0]].getOpenness_imagination()%>, <%=users[idx1[0]].getOpenness_intellect()%>, <%=users[idx1[0]].getOpenness_authority_challenging()%>]
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

<div><a href="javascript:void(0)" id="category_conscientiousness1" onclick="show_layer('conscientiousness1');">
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと <%=( String )obj.get( "conscientiousness" )%> が遠いのは <%=users[idx1[1]].getName()%><img src="<%=app.getProfileImageURL( users[idx1[1]].getTw_id() )%>" width="24" height="24" title="<%=users[idx1[1]].getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=users[idx1[1]].getTw_id()%>">&gt;&gt;</a></div>

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
            label: "<%=users[idx1[1]].getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=users[idx1[1]].getConscientiousness_achievement_striving()%>, <%=users[idx1[1]].getConscientiousness_cautiousness()%>, <%=users[idx1[1]].getConscientiousness_dutifulness()%>, <%=users[idx1[1]].getConscientiousness_orderliness()%>, <%=users[idx1[1]].getConscientiousness_self_discipline()%>, <%=users[idx1[1]].getConscientiousness_self_efficacy()%>]
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

<div><a href="javascript:void(0)" id="category_extraversion1" onclick="show_layer('extraversion1');">
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと <%=( String )obj.get( "extraversion" )%> が遠いのは <%=users[idx1[2]].getName()%><img src="<%=app.getProfileImageURL( users[idx1[2]].getTw_id() )%>" width="24" height="24" title="<%=users[idx1[2]].getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=users[idx1[2]].getTw_id()%>">&gt;&gt;</a></div>

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
            label: "<%=users[idx1[2]].getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=users[idx1[2]].getExtraversion_activity_level()%>, <%=users[idx1[2]].getExtraversion_assertiveness()%>, <%=users[idx1[2]].getExtraversion_cheerfulness()%>, <%=users[idx1[2]].getExtraversion_excitement_seeking()%>, <%=users[idx1[2]].getExtraversion_outgoing()%>, <%=users[idx1[2]].getExtraversion_gregariousness()%>]
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

<div><a href="javascript:void(0)" id="category_agreeableness1" onclick="show_layer('agreeableness1');">
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと <%=( String )obj.get( "agreeableness" )%> が遠いのは <%=users[idx1[3]].getName()%><img src="<%=app.getProfileImageURL( users[idx1[3]].getTw_id() )%>" width="24" height="24" title="<%=users[idx1[3]].getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=users[idx1[3]].getTw_id()%>">&gt;&gt;</a></div>

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
            label: "<%=users[idx0[3]].getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=users[idx1[3]].getAgreeableness_altruism()%>, <%=users[idx1[3]].getAgreeableness_cooperation()%>, <%=users[idx1[3]].getAgreeableness_modesty()%>, <%=users[idx1[3]].getAgreeableness_uncompromising()%>, <%=users[idx1[3]].getAgreeableness_sympathy()%>, <%=users[idx1[3]].getAgreeableness_trust()%>]
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

<div><a href="javascript:void(0)" id="category_emotional_range1" onclick="show_layer('emotional_range1');">
<%=me.getName()%><img src="<%=app.getProfileImageURL( me.getTw_id() )%>" width="24" height="24" title="<%=me.getTw_id()%>"/>さんと <%=( String )obj.get( "emotional_range" )%> が遠いのは <%=users[idx1[4]].getName()%><img src="<%=app.getProfileImageURL( users[idx1[4]].getTw_id() )%>" width="24" height="24" title="<%=users[idx1[4]].getTw_id()%>"/>さんでした。
</a> <a target="_blank" href="http://twitter.com/<%=users[idx1[4]].getTw_id()%>">&gt;&gt;</a></div>

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
            label: "<%=users[idx1[4]].getName()%>",
            backgroundColor: "rgba(255,99,132,0.2)",
            borderColor: "rgba(255,99,132,1)",
            pointBackgroundColor: "rgba(255,99,132,1)",
            pointBorderColor: "#fff",
            pointHoverBackgroundColor: "#fff",
            pointHoverBorderColor: "rgba(255,99,132,1)",
            data: [<%=users[idx1[4]].getEmotional_range_fiery()%>, <%=users[idx1[4]].getEmotional_range_prone_to_worry()%>, <%=users[idx1[4]].getEmotional_range_melancholy()%>, <%=users[idx1[4]].getEmotional_range_immoderation()%>, <%=users[idx1[4]].getEmotional_range_self_consciousness()%>, <%=users[idx1[4]].getEmotional_range_susceptible_to_stress()%>]
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
<table border="0">
<tr>
<td>
<a target="_blank" href="http://twitter.com/share?url=http%3A%2F%2Fakb-finder.mybluemix.net%2Fresult.jsp%3Fid%3D<%=me.getTw_id()%>&text=自分の性格はこのAKBメンバーと似ているらしいです。。"><img src="./tw.png"/></a>
</td>
<td>
<a target="_blank" href="http://www.facebook.com/sharer.php?u=http%3A%2F%2Fakb-finder.mybluemix.net%2Fresult.jsp%3Fid%3D<%=me.getTw_id()%>&text=自分の性格はこのAKBメンバーと似ているらしいです。。" rel="nofollow"><img src="./fb.png"/></a>
</td>
</tr>
</table>
</div>

<%
	//. 記録
	Member member = new Member( me.getId(), me.getTw_id(), me.getName()
		, me.getOpenness_adventurousness(), me.getOpenness_artistic_interests(), me.getOpenness_emotionality(), me.getOpenness_imagination(), me.getOpenness_intellect(), me.getOpenness_authority_challenging()
		, me.getConscientiousness_achievement_striving(), me.getConscientiousness_cautiousness(), me.getConscientiousness_dutifulness(), me.getConscientiousness_orderliness(), me.getConscientiousness_self_discipline(), me.getConscientiousness_self_efficacy()
		, me.getExtraversion_activity_level(), me.getExtraversion_assertiveness(), me.getExtraversion_cheerfulness(), me.getExtraversion_excitement_seeking(), me.getExtraversion_outgoing(), me.getExtraversion_gregariousness()
		, me.getAgreeableness_altruism(), me.getAgreeableness_cooperation(), me.getAgreeableness_modesty(), me.getAgreeableness_uncompromising(), me.getAgreeableness_sympathy(), me.getAgreeableness_trust()
		, me.getEmotional_range_fiery(), me.getEmotional_range_prone_to_worry(), me.getEmotional_range_melancholy(), me.getEmotional_range_immoderation(), me.getEmotional_range_self_consciousness(), me.getEmotional_range_susceptible_to_stress()
		, users[idx0[5]].getTw_id(), users[idx0[0]].getTw_id(), users[idx0[1]].getTw_id(), users[idx0[2]].getTw_id(), users[idx0[3]].getTw_id(), users[idx0[4]].getTw_id()
		, users[idx1[5]].getTw_id(), users[idx1[0]].getTw_id(), users[idx1[1]].getTw_id(), users[idx1[2]].getTw_id(), users[idx1[3]].getTw_id(), users[idx1[4]].getTw_id()
		, me.getUpdated()		
	);
	app.updateMember( member );
}else if( tw_id != null && tw_id.length() > 0 ){
%>
<!-- ユーザー情報が取得できなかった／性格分析結果が取得できなかった -->
<div class="alert alert-warning alert-dismissible" role="alert" style="padding:20px 20px">
<button type="button" class="close" data-dismiss="alert" aria-label="閉じる"><span aria-hidden="true">×</span></button>
なんらかの原因で性格分析ができませんでした。ユーザー情報が正しく取得できなかったか、あるいは性格分析に必要なツイートが取得できなかった可能性があります。
</div>
<%
}
%>

<p/>

<jsp:include page="foot.jsp">
  <jsp:param name="page" value="index"/>
</jsp:include>

</body>
</html>

