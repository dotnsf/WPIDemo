package me.juge.wpidemo;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import net.spy.memcached.AddrUtil;
import net.spy.memcached.ConnectionFactoryBuilder;
import net.spy.memcached.MemcachedClient;
import net.spy.memcached.auth.AuthDescriptor;
import net.spy.memcached.auth.PlainCallbackHandler;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.methods.PostMethod;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;


/*
 * 1. Bluemix で使う場合、以下のランタイムとサービスをバインドする
 *  ランタイム： Liberty Java（メモリは1GB程度）
 *  サービス: ClearDB（無料プラン）
 *  サービス: Memcached Cloud（無料プラン）
 *  サービス: Watson Personality Insights
 * 
 * 2. この下の Twitter API のキーとシークレット情報を取得する
 *  Java ランタイムの名前に合わせたホスト名を指定して取得すること（そうしないと Twitter OAuth が動かない）
 *  
 * 3. 同様にこの下の mm_keyname 変数の値を設定
 *  このままでもいいが、同じ memcached サービスに対して同じキーは１つしか使えないことに注意
 * 
 * 4. 同様にこの下の twitter_ids 変数の値を設定
 *  性格分析を行って比較の対象とする人達の Twitter ID を配列で指定
 * 
 * 5. footer.jsp の内容を編集
 *  AKBグループの人と性格分析比較をする、という前提で記載されている箇所があるため。
 * 
 * 6. InitTables.java と resetMM.java をそれぞれ一回ずつ実行する
 *  前者は MySQL にテーブルを作成するコマンド、後者は対象ID全員分の性格分析を行ってデータベース化しておくためのコマンド
 * 
 * 7. このプロジェクトをアプリケーションサーバー（ランタイム）にデプロイして利用
 */

public class App {
	private static final Logger log = Logger.getLogger( App.class.getName() );
	
	//. ↓以下の情報を実際の情報に併せて書き換える
	
	//. Twitter API のキーとシークレット(運用時の http://****.mybluemix.net/ のホスト名にあわせて https://apps.twitter.com/ で作成して取得)
	//. 参照: http://dotnsf.blog.jp/archives/1044796238.html
	public String tw_consumer_key = "(TW_CONSUMER_KEY)", tw_consumer_secret = "(TW_CONSUMER_SECRET)";
	//. memcached に格納する際のキー文字列（任意文字列だが、同じ memcached に対して同じものは使えない）
	public String mm_keyname = "akb_twitter";
	
	//. 性格分析対象の Twitter IDs
	String[] target_ids = {
			// AKB48
			"iriyamaanna1203",  //. 入山 杏奈
			"ooyachaaan1228",  //. 大家 志津香
			"nattsun20",  //. 小嶋 菜月
			"paruruchan0330",  //. 島崎 遥香
			"shiromiru36",  //. 白間 美瑠
			"chiyori_n512",  //. 中西 智代梨 
			"marikorima1216",  //. 中村 麻里子
			"hirari_official",  //. 平田 梨奈
			"730myao",  //. 宮崎 美穂
			"Yui_yoko1208",  //. 横山 由依
			"shimada_hrk1216",  //. 島田 晴香
			"mariyannu_s",  //. 鈴木 まりや
			"tanoyuka_0307",  //. 田野 優花
			"fujitanana_1228",  //. 藤田 奈那 
			"chan__31",  //. 峯岸 みなみ
			"sayakaneon",  //. 山本 彩
			"oshimaryoka_48",  //. 大島 涼花
			"yukiriiiin__k",  //. 柏木 由紀
			"katorena_akb48",  //. 加藤 玲奈
			"yuriaaa_peace",  //. 木﨑 ゆりあ
			"karaage_mayu",  //. 渡辺 麻友
			"_nagisa_shibuya",  //. 渋谷 凪咲
			// SKE48
			"rion_az13",  //. 東 李苑
			"daisuki_wan",  //. 犬塚 あさな
			"takeuchimai0831",  //. 竹内 舞
			"harutamchan",  //. 二村 春香
			"jurina38g",  //. 松井 珠理奈
			"suzuranchan1208",  //. 山内 鈴蘭
			"oshirin_dayo",  //. 青木 詩織
			"mina_ovo",  //. 大場 美奈
			"sodasarinachan",  //. 惣田 紗莉渚
			"akane29_o8o",  //. 高柳 明音
			"nacky_k829",  //. 鎌田 菜月
			"saitomakiko_628",  //. 斉藤 真木子
			"sumire_princess",  //. 佐藤 すみれ
			"dasuwaikaa",  //. 須田 亜香里
			"tanimarika0105",  //. 谷 真理佳
			// NMB48
			"nattu817",  //. 明石 奈津子
			"yuumi_1012",  //. 石田 優美
			"yuuriso_1201",  //. 太田 夢莉
			"u_ka0801",  //. 加藤 夕夏
			"kishinorikadayo",  //. 岸野 里香
			"naru3official30",  //. 古賀 成美
			"jmd12tpj85",  //. 城 恵理子
			"riripon48",  //. 須藤 凜々花
			"2430rurina_G",  //. 西澤 瑠莉奈
			"yamarina_1210",  //. 山尾 梨奈
			"sayakaneon",  //. 山本 彩
			"_yoshida_akari",  //. 吉田 朱里
			"yukitsun_0217",  //. 東 由樹
			"akari_0711",  //. 石塚 朱莉
			"o2o4__azusa",  //. 植村 梓
			"ayaka1o11",  //. 沖田 彩華
			"renapyon_udon",  //. 川上 礼奈
			"Rinacchi_NMB48",  //. 久代 梨奈
			"shiromiru36",  //. 白間 美瑠
			"sararn1006",  //. 武井 紗良
			"Nakano_Reina1M",  //. 中野 麗来
			"nya_n017",  //. 藤江 れいな
			"meguumin_48",  //. 松村 芽久未
			"kyunmao_m99",  //. 三田 麻央
			"murasesae_0330",  //. 村瀬 紗英
			"ayatyeen_luv",  //. 森田 彩花
			"ICECREAMFUKO",  //. 矢倉 楓子
			"ijirianna0120",  //. 井尻 晏菜
			"isokana89",  //. 磯 佳奈江
			"miorin_lemon212",  //. 市川 美織
			"mipyon0202",  //. 植田 碧麗
			"maichi_2014",  //. 大段 舞依
			"emika_kamieda",  //. 上枝 恵美加
			"enoki_zzz0112",  //. 日下 このみ
			"box_in_the_hako",  //. 黒川 葉月
			"_nagisa_shibuya",  //. 渋谷 凪咲
			"naiki_cocoro",  //. 内木 志
			"moka9_11",  //. 林 萌々香
			"matsuokachiho",  //. 松岡 知穂
			"Shu__1202",  //. 薮下 柊
			// HKT48
			"345__chan",  //. 指原 莉乃
			// NGT48
			"yukiriiiin__k",  //. 柏木 由紀
			"Rie_Kitahara3",  //. 北原 里英
			// SNH48
			"mariyannu_s"  //. 鈴木 まりや
	};
	
	//. ↑以上の情報を実際の情報に併せて書き換える
	
	
	//. Personality Insights の username と password（URL は変更不要）
	String pi_username = "(PI_USERNAME)", pi_password = "(PI_PASSWORD)", pi_url = "https://gateway.watsonplatform.net/personality-insights/api";

	//. MySQL(ClearDB) の username と password, url, db 名
	String mysql_username = "(MySQL_USERNAME)", mysql_password = "(MySQL_PASSWORD)", mysql_hostname = "(MySQL_HOSTNAME)", mysql_db = "(MySQL_DBNAME)";
	int mysql_port = 3306;
	
	//. Memcached Cloud の username と password, server, keyname（keyname は自分で一意の文字列を決めて指定）
	String mm_username = "(MM_USERNAME)", mm_password = "(MM_PASSWORD)", mm_server = "(MM_SERVER)";
	int mm_port = 19606;
	
	//. 訳
	public String big5 = "{"
			+ "\"openness\":\"心の開放度合い\","
			+ "\"openness_adventurousness\":\"冒険心の強さ\","
			+ "\"openness_artistic_interests\":\"美の理解・興味\","
			+ "\"openness_emotionality\":\"情に流されやすさ\","
			+ "\"openness_imagination\":\"想像力のたくましさ\","
			+ "\"openness_intellect\":\"知性・知的さ\","
			+ "\"openness_authority_challenging\":\"権力への対抗心の強さ\","
			+ "\"conscientiousness\":\"まじめレベル\","
			+ "\"conscientiousness_achievement_striving\":\"達成への努力を惜しまない\","
			+ "\"conscientiousness_cautiousness\":\"物事を慎重に進める\","
			+ "\"conscientiousness_dutifulness\":\"ルールに忠実\","
			+ "\"conscientiousness_orderliness\":\"秩序を守って行動する\","
			+ "\"conscientiousness_self_discipline\":\"自己訓練を惜しまない\","
			+ "\"conscientiousness_self_efficacy\":\"求められた行動を正しく遂行できる\","
			+ "\"extraversion\":\"外向性\","
			+ "\"extraversion_activity_level\":\"活動レベル\","
			+ "\"extraversion_assertiveness\":\"積極的になれる\","
			+ "\"extraversion_cheerfulness\":\"陽気さ\","
			+ "\"extraversion_excitement_seeking\":\"エキサイトすることを求める\","
			+ "\"extraversion_outgoing\":\"社交性がある\","
			+ "\"extraversion_gregariousness\":\"人と集まって行動するのが好き\","
			+ "\"agreeableness\":\"協調性\","
			+ "\"agreeableness_altruism\":\"周りに配慮できる\","
			+ "\"agreeableness_cooperation\":\"協力的な姿勢を意識する\","
			+ "\"agreeableness_modesty\":\"謙虚さがある\","
			+ "\"agreeableness_uncompromising\":\"妥協はしない\","
			+ "\"agreeableness_sympathy\":\"相手の立場に同情することができる\","
			+ "\"agreeableness_trust\":\"信頼できる\","
			+ "\"emotional_range\":\"感情性\","
			+ "\"emotional_range_fiery\":\"怒りっぽい、すぐ感情的になる\","
			+ "\"emotional_range_prone_to_worry\":\"心配性\","
			+ "\"emotional_range_melancholy\":\"憂鬱になる\","
			+ "\"emotional_range_immoderation\":\"過度に反応する\","
			+ "\"emotional_range_self_consciousness\":\"自意識過剰\","
			+ "\"emotional_range_susceptible_to_stress\":\"ストレスの影響を受けやすい\""
			+ "}";

	public App(){
		//. for BlueMix
		JSONParser parser = new JSONParser();
		String env = System.getenv( "VCAP_SERVICES" );
		if( env != null && env.length() > 0 ){
			try{
				JSONObject obj = ( JSONObject )parser.parse( env );

				JSONArray cleardb_array = ( JSONArray )obj.get( "twitterinsights" );
				JSONObject cleardb = ( JSONObject )cleardb_array.get( 0 );
				JSONObject credentials1 = ( JSONObject )cleardb.get( "credentials" );
				mysql_username = ( String )credentials1.get( "username" );
				mysql_password = ( String )credentials1.get( "password" );
				mysql_hostname = ( String )credentials1.get( "host" );
				mysql_db = ( String )credentials1.get( "name" );
				
				JSONArray memcachedcloud_array = ( JSONArray )obj.get( "memcachedcloud" );
				JSONObject memcachedcloud = ( JSONObject )memcachedcloud_array.get( 0 );
				JSONObject credentials2 = ( JSONObject )memcachedcloud.get( "credentials" );
				mm_username = ( String )credentials2.get( "username" );
				mm_password = ( String )credentials2.get( "password" );
				String mm_servers = ( String )credentials2.get( "servers" );
				String[] tmp = mm_servers.split( ":" );
				mm_server = tmp[0];
				mm_port = Integer.parseInt( tmp[1] );
				
				JSONArray pi_array = ( JSONArray )obj.get( "memcachedcloud" );
				JSONObject pi = ( JSONObject )memcachedcloud_array.get( 0 );
				JSONObject credentials3 = ( JSONObject )pi.get( "credentials" );
				pi_username = ( String )credentials3.get( "username" );
				pi_password = ( String )credentials3.get( "password" );
				pi_url = ( String )credentials3.get( "url" );
			}catch( Exception e ){
			}
		}

	}
	
	public User[] getAllUsers(){
		return getAllUsers( true );
	}
	public User[] getAllUsers( boolean forceDB ){
		User[] users = null;
		if( forceDB ){
			try{
				Connection conn = getConnection();
				if( conn != null ){
					List<User> list = new ArrayList<User>();
					String sql = "select * from users";
					Statement stmt = conn.createStatement();
					ResultSet rs = stmt.executeQuery( sql );
					while( rs.next() ){
						long id = rs.getLong( 1 );
						String tw_id = rs.getString( 2 );
						String name = rs.getString( 3 );
						double openness_adventurousness = rs.getDouble( 4 );
						double openness_artistic_interests = rs.getDouble( 5 );
						double openness_emotionality = rs.getDouble( 6 );
						double openness_imagination = rs.getDouble( 7 );
						double openness_intellect = rs.getDouble( 8 );
						double openness_authority_challenging = rs.getDouble( 9 );
						double conscientiousness_achivement_striving = rs.getDouble( 10 );
						double conscientiousness_cautiousness = rs.getDouble( 11 );
						double conscientiousness_dutifulness = rs.getDouble( 12 );
						double conscientiousness_orderliness = rs.getDouble( 13 );
						double conscientiousness_self_discipline = rs.getDouble( 14 );
						double conscientiousness_self_efficacy = rs.getDouble( 15 );
						double extraversion_activity_level = rs.getDouble( 16 );
						double extraversion_assertiveness = rs.getDouble( 17 );
						double extraversion_cheerfulness = rs.getDouble( 18 );
						double extraversion_excitement_seeking = rs.getDouble( 19 );
						double extraversion_outgoing = rs.getDouble( 20 );
						double extraversion_gregariousness = rs.getDouble( 21 );
						double agreebleness_altruism = rs.getDouble( 22 );
						double agreebleness_cooperation = rs.getDouble( 23 );
						double agreebleness_modesty = rs.getDouble( 24 );
						double agreebleness_uncompromising = rs.getDouble( 25 );
						double agreebleness_sympathy = rs.getDouble( 26 );
						double agreebleness_trust = rs.getDouble( 27 );
						double emotionalrange_fiery = rs.getDouble( 28 );
						double emotionalrange_prone_to_worry = rs.getDouble( 29 );
						double emotionalrange_melancholy = rs.getDouble( 30 );
						double emotionalrange_immoderation = rs.getDouble( 31 );
						double emotionalrange_self_consciousness = rs.getDouble( 32 );
						double emotionalrange_susceptible_to_stress = rs.getDouble( 33 );
						String updated = rs.getString( 34 );

						User user = new User( id, tw_id, name,
								openness_adventurousness, openness_artistic_interests, openness_emotionality, openness_imagination, openness_intellect, openness_authority_challenging, 
								conscientiousness_achivement_striving, conscientiousness_cautiousness, conscientiousness_dutifulness, conscientiousness_orderliness, conscientiousness_self_discipline, conscientiousness_self_efficacy,
								extraversion_activity_level, extraversion_assertiveness, extraversion_cheerfulness, extraversion_excitement_seeking, extraversion_outgoing, extraversion_gregariousness,
								agreebleness_altruism, agreebleness_cooperation, agreebleness_modesty, agreebleness_uncompromising, agreebleness_sympathy, agreebleness_trust,
								emotionalrange_fiery, emotionalrange_prone_to_worry, emotionalrange_melancholy, emotionalrange_immoderation, emotionalrange_self_consciousness, emotionalrange_susceptible_to_stress,
								updated );
						list.add( user );
					}
					
					rs.close();
					stmt.close();
					
					users = ( User[] )list.toArray( new User[0] );
				}
				conn.close();
			}catch( Exception e ){
				e.printStackTrace();
			}
		}else{
			users = getAllMMUsers();
			if( users == null || users.length == 0 ){
				return getAllUsers( true );
			}
		}
		
		return users;
	}
	
	public User getUser( long id ){
		User user = getMMUser( "" + id );
		if( user == null ){
			try{
				Connection conn = getConnection();
				if( conn != null && id > 0 ){
					String sql = "select * from users where id = " + id;
					Statement stmt = conn.createStatement();
					ResultSet rs = stmt.executeQuery( sql );
					if( rs.next() ){
						//long id = rs.getLong( 1 );
						String tw_id = rs.getString( 2 );
						String name = rs.getString( 3 );
						double openness_adventurousness = rs.getDouble( 4 );
						double openness_artistic_interests = rs.getDouble( 5 );
						double openness_emotionality = rs.getDouble( 6 );
						double openness_imagination = rs.getDouble( 7 );
						double openness_intellect = rs.getDouble( 8 );
						double openness_authority_challenging = rs.getDouble( 9 );
						double conscientiousness_achivement_striving = rs.getDouble( 10 );
						double conscientiousness_cautiousness = rs.getDouble( 11 );
						double conscientiousness_dutifulness = rs.getDouble( 12 );
						double conscientiousness_orderliness = rs.getDouble( 13 );
						double conscientiousness_self_discipline = rs.getDouble( 14 );
						double conscientiousness_self_efficacy = rs.getDouble( 15 );
						double extraversion_activity_level = rs.getDouble( 16 );
						double extraversion_assertiveness = rs.getDouble( 17 );
						double extraversion_cheerfulness = rs.getDouble( 18 );
						double extraversion_excitement_seeking = rs.getDouble( 19 );
						double extraversion_outgoing = rs.getDouble( 20 );
						double extraversion_gregariousness = rs.getDouble( 21 );
						double agreebleness_altruism = rs.getDouble( 22 );
						double agreebleness_cooperation = rs.getDouble( 23 );
						double agreebleness_modesty = rs.getDouble( 24 );
						double agreebleness_uncompromising = rs.getDouble( 25 );
						double agreebleness_sympathy = rs.getDouble( 26 );
						double agreebleness_trust = rs.getDouble( 27 );
						double emotionalrange_fiery = rs.getDouble( 28 );
						double emotionalrange_prone_to_worry = rs.getDouble( 29 );
						double emotionalrange_melancholy = rs.getDouble( 30 );
						double emotionalrange_immoderation = rs.getDouble( 31 );
						double emotionalrange_self_consciousness = rs.getDouble( 32 );
						double emotionalrange_susceptible_to_stress = rs.getDouble( 33 );
						String updated = rs.getString( 34 );

						user = new User( id, tw_id, name,
								openness_adventurousness, openness_artistic_interests, openness_emotionality, openness_imagination, openness_intellect, openness_authority_challenging, 
								conscientiousness_achivement_striving, conscientiousness_cautiousness, conscientiousness_dutifulness, conscientiousness_orderliness, conscientiousness_self_discipline, conscientiousness_self_efficacy,
								extraversion_activity_level, extraversion_assertiveness, extraversion_cheerfulness, extraversion_excitement_seeking, extraversion_outgoing, extraversion_gregariousness,
								agreebleness_altruism, agreebleness_cooperation, agreebleness_modesty, agreebleness_uncompromising, agreebleness_sympathy, agreebleness_trust,
								emotionalrange_fiery, emotionalrange_prone_to_worry, emotionalrange_melancholy, emotionalrange_immoderation, emotionalrange_self_consciousness, emotionalrange_susceptible_to_stress,
								updated );
					}
					
					rs.close();
					stmt.close();
				}
				conn.close();
				
			}catch( Exception e ){
				e.printStackTrace();
			}
		}
		
		return user;
	}

	public User getUser( String tw_id ){
		User user = getMMUser( tw_id );
		if( user == null ){
			try{
				Connection conn = getConnection();
				if( conn != null && tw_id != null && tw_id.length() > 0 ){
					String sql = "select * from users where tw_id = '" + tw_id + "'";
					Statement stmt = conn.createStatement();
					ResultSet rs = stmt.executeQuery( sql );
					if( rs.next() ){
						long id = rs.getLong( 1 );
						//String tw_id = rs.getString( 2 );
						String name = rs.getString( 3 );
						double openness_adventurousness = rs.getDouble( 4 );
						double openness_artistic_interests = rs.getDouble( 5 );
						double openness_emotionality = rs.getDouble( 6 );
						double openness_imagination = rs.getDouble( 7 );
						double openness_intellect = rs.getDouble( 8 );
						double openness_authority_challenging = rs.getDouble( 9 );
						double conscientiousness_achivement_striving = rs.getDouble( 10 );
						double conscientiousness_cautiousness = rs.getDouble( 11 );
						double conscientiousness_dutifulness = rs.getDouble( 12 );
						double conscientiousness_orderliness = rs.getDouble( 13 );
						double conscientiousness_self_discipline = rs.getDouble( 14 );
						double conscientiousness_self_efficacy = rs.getDouble( 15 );
						double extraversion_activity_level = rs.getDouble( 16 );
						double extraversion_assertiveness = rs.getDouble( 17 );
						double extraversion_cheerfulness = rs.getDouble( 18 );
						double extraversion_excitement_seeking = rs.getDouble( 19 );
						double extraversion_outgoing = rs.getDouble( 20 );
						double extraversion_gregariousness = rs.getDouble( 21 );
						double agreebleness_altruism = rs.getDouble( 22 );
						double agreebleness_cooperation = rs.getDouble( 23 );
						double agreebleness_modesty = rs.getDouble( 24 );
						double agreebleness_uncompromising = rs.getDouble( 25 );
						double agreebleness_sympathy = rs.getDouble( 26 );
						double agreebleness_trust = rs.getDouble( 27 );
						double emotionalrange_fiery = rs.getDouble( 28 );
						double emotionalrange_prone_to_worry = rs.getDouble( 29 );
						double emotionalrange_melancholy = rs.getDouble( 30 );
						double emotionalrange_immoderation = rs.getDouble( 31 );
						double emotionalrange_self_consciousness = rs.getDouble( 32 );
						double emotionalrange_susceptible_to_stress = rs.getDouble( 33 );
						String updated = rs.getString( 34 );

						user = new User( id, tw_id, name,
								openness_adventurousness, openness_artistic_interests, openness_emotionality, openness_imagination, openness_intellect, openness_authority_challenging, 
								conscientiousness_achivement_striving, conscientiousness_cautiousness, conscientiousness_dutifulness, conscientiousness_orderliness, conscientiousness_self_discipline, conscientiousness_self_efficacy,
								extraversion_activity_level, extraversion_assertiveness, extraversion_cheerfulness, extraversion_excitement_seeking, extraversion_outgoing, extraversion_gregariousness,
								agreebleness_altruism, agreebleness_cooperation, agreebleness_modesty, agreebleness_uncompromising, agreebleness_sympathy, agreebleness_trust,
								emotionalrange_fiery, emotionalrange_prone_to_worry, emotionalrange_melancholy, emotionalrange_immoderation, emotionalrange_self_consciousness, emotionalrange_susceptible_to_stress,
								updated );
					}
					
					rs.close();
					stmt.close();
				}
				conn.close();
				
			}catch( Exception e ){
				e.printStackTrace();
			}
		}
		
		return user;
	}

	public Member getMember( String tw_id ){
		Member member = null;
		
		try{
			Connection conn = getConnection();
			if( conn != null && tw_id != null && tw_id.length() > 0 ){
				String sql = "select * from members where tw_id = '" + tw_id + "'";
				Statement stmt = conn.createStatement();
				ResultSet rs = stmt.executeQuery( sql );
				if( rs.next() ){
					long id = rs.getLong( 1 );
					//String tw_id = rs.getString( 2 );
					String name = rs.getString( 3 );
					double openness_adventurousness = rs.getDouble( 4 );
					double openness_artistic_interests = rs.getDouble( 5 );
					double openness_emotionality = rs.getDouble( 6 );
					double openness_imagination = rs.getDouble( 7 );
					double openness_intellect = rs.getDouble( 8 );
					double openness_authority_challenging = rs.getDouble( 9 );
					double conscientiousness_achivement_striving = rs.getDouble( 10 );
					double conscientiousness_cautiousness = rs.getDouble( 11 );
					double conscientiousness_dutifulness = rs.getDouble( 12 );
					double conscientiousness_orderliness = rs.getDouble( 13 );
					double conscientiousness_self_discipline = rs.getDouble( 14 );
					double conscientiousness_self_efficacy = rs.getDouble( 15 );
					double extraversion_activity_level = rs.getDouble( 16 );
					double extraversion_assertiveness = rs.getDouble( 17 );
					double extraversion_cheerfulness = rs.getDouble( 18 );
					double extraversion_excitement_seeking = rs.getDouble( 19 );
					double extraversion_outgoing = rs.getDouble( 20 );
					double extraversion_gregariousness = rs.getDouble( 21 );
					double agreebleness_altruism = rs.getDouble( 22 );
					double agreebleness_cooperation = rs.getDouble( 23 );
					double agreebleness_modesty = rs.getDouble( 24 );
					double agreebleness_uncompromising = rs.getDouble( 25 );
					double agreebleness_sympathy = rs.getDouble( 26 );
					double agreebleness_trust = rs.getDouble( 27 );
					double emotionalrange_fiery = rs.getDouble( 28 );
					double emotionalrange_prone_to_worry = rs.getDouble( 29 );
					double emotionalrange_melancholy = rs.getDouble( 30 );
					double emotionalrange_immoderation = rs.getDouble( 31 );
					double emotionalrange_self_consciousness = rs.getDouble( 32 );
					double emotionalrange_susceptible_to_stress = rs.getDouble( 33 );

					String updated = rs.getString( 34 );

					String top_tw_id0 = rs.getString( 35 );
					String openness_tw_id0 = rs.getString( 36 );
					String conscientiousness_tw_id0 = rs.getString( 37 );
					String extraversion_tw_id0 = rs.getString( 38 );
					String agreeableness_tw_id0 = rs.getString( 39 );
					String emotional_range_tw_id0 = rs.getString( 40 );
					String top_tw_id1 = rs.getString( 41 );
					String openness_tw_id1 = rs.getString( 42 );
					String conscientiousness_tw_id1 = rs.getString( 43 );
					String extraversion_tw_id1 = rs.getString( 44 );
					String agreeableness_tw_id1 = rs.getString( 45 );
					String emotional_range_tw_id1 = rs.getString( 46 );
					

					member = new Member( id, tw_id, name,
							openness_adventurousness, openness_artistic_interests, openness_emotionality, openness_imagination, openness_intellect, openness_authority_challenging, 
							conscientiousness_achivement_striving, conscientiousness_cautiousness, conscientiousness_dutifulness, conscientiousness_orderliness, conscientiousness_self_discipline, conscientiousness_self_efficacy,
							extraversion_activity_level, extraversion_assertiveness, extraversion_cheerfulness, extraversion_excitement_seeking, extraversion_outgoing, extraversion_gregariousness,
							agreebleness_altruism, agreebleness_cooperation, agreebleness_modesty, agreebleness_uncompromising, agreebleness_sympathy, agreebleness_trust,
							emotionalrange_fiery, emotionalrange_prone_to_worry, emotionalrange_melancholy, emotionalrange_immoderation, emotionalrange_self_consciousness, emotionalrange_susceptible_to_stress,
							top_tw_id0, openness_tw_id0, conscientiousness_tw_id0, extraversion_tw_id0, agreeableness_tw_id0, emotional_range_tw_id0,
							top_tw_id1, openness_tw_id1, conscientiousness_tw_id1, extraversion_tw_id1, agreeableness_tw_id1, emotional_range_tw_id1,
							updated );
				}
				
				rs.close();
				stmt.close();
			}
			conn.close();
		}catch( Exception e ){
			e.printStackTrace();
		}
		
		return member;
	}

	public int updateUser( String tw_id ){
		int r = -1;
		
		try{
			Connection conn = getConnection();
			if( conn != null && tw_id != null && tw_id.length() > 0 ){
				r = 0;
				long id = -1;
				String name = "";
				
				List<User> list = new ArrayList<User>();
				
				//. 既に登録されているか？
				String sql = "select id from users where tw_id = '" + tw_id + "'";
				Statement stmt = conn.createStatement();
				ResultSet rs = stmt.executeQuery( sql );
				if( rs.next() ){
					id = rs.getLong( 1 );
				}
				rs.close();
				stmt.close();
				
				//. 最新のユーザー情報を取得
				App app = new App();
				String[] userInfo = app.getTwitterUserInfo( tw_id );
				
				//. ツイートを取得
				String tweets = app.getTweets( tw_id );
				
				//. Personality Insights
				Map<String,Double> pi = app.getPersonalityInsights( tweets );
				if( pi != null ){
					//. 現在時刻
					String updated = app.getCurrentDateTime();
					
					if( id > -1 ){
						//. 更新
						sql = "update users set name = '" + name + "', updated = '" + updated + "'";
						for( Map.Entry<String, Double>m : pi.entrySet() ){
							String key = m.getKey();
							Double value = m.getValue();
							
							sql += ( ", " + key + " = " + value );
						}
						sql += ( " where id = " + id );
					}else{
						//. 追加
						String sql1 = "id, tw_id, name, updated";
						String sql2 = userInfo[0] + ",'" + tw_id + "','" + userInfo[1] + "', '" + updated + "'";
						
						for( Map.Entry<String, Double>m : pi.entrySet() ){
							String key = m.getKey();
							Double value = m.getValue();
							
							sql1 += ( ", " + key );
							sql2 += ( ", " + value );
						}

						sql = "insert into users( " + sql1 + ") values( " + sql2 + ")";
					}
					
					try{
						System.out.println( "tw_id = " + tw_id );
						System.out.println( "sql = " + sql );
						stmt = conn.createStatement();
						r = stmt.executeUpdate( sql );
						System.out.println( " -> " + r );
						stmt.close();
					}catch( Exception e ){
						e.printStackTrace();
					}
				}
			}
			conn.close();
		}catch( Exception e ){
			e.printStackTrace();
		}
		
		return r;
	}
	
	public int updateMember( Member member ){
		int r = -1;
		
		try{
			Connection conn = getConnection();
			if( conn != null && member != null ){
				r = 0;
				long id = -1;
				
				List<User> list = new ArrayList<User>();
				
				//. 既に登録されているか？
				String sql = "select id from members where tw_id = '" + member.getTw_id() + "'";
				Statement stmt = conn.createStatement();
				ResultSet rs = stmt.executeQuery( sql );
				if( rs.next() ){
					id = rs.getLong( 1 );
				}
				rs.close();
				stmt.close();
				
				//. 最新のユーザー情報を取得
				App app = new App();

				if( id > -1 ){
					//. 更新
					sql = "update members set"
							+ " name = '" + member.getName() + "',"
//							+ " tw_id = '" + member.getTw_id() + "',"
							+ " openness_adventurousness = " + member.getOpenness_adventurousness() + ","
							+ " openness_artistic_interests = " + member.getOpenness_artistic_interests() + ","
							+ " openness_emotionality = " + member.getOpenness_emotionality() + ","
							+ " openness_imagination = " + member.getOpenness_imagination() + ","
							+ " openness_intellect = " + member.getOpenness_intellect() + ","
							+ " openness_authority_challenging = " + member.getOpenness_authority_challenging() + ","
							+ " conscientiousness_achievement_striving = " + member.getConscientiousness_achievement_striving() + ","
							+ " conscientiousness_cautiousness = " + member.getConscientiousness_cautiousness() + ","
							+ " conscientiousness_dutifulness = " + member.getConscientiousness_dutifulness() + ","
							+ " conscientiousness_orderliness = " + member.getConscientiousness_orderliness() + ","
							+ " conscientiousness_self_discipline = " + member.getConscientiousness_self_discipline() + ","
							+ " conscientiousness_self_efficacy = " + member.getConscientiousness_self_efficacy() + ","
							+ " extraversion_activity_level = " + member.getExtraversion_activity_level() + ","
							+ " extraversion_assertiveness = " + member.getExtraversion_assertiveness() + ","
							+ " extraversion_cheerfulness = " + member.getExtraversion_cheerfulness() + ","
							+ " extraversion_excitement_seeking = " + member.getExtraversion_excitement_seeking() + ","
							+ " extraversion_outgoing = " + member.getExtraversion_outgoing() + ","
							+ " extraversion_gregariousness = " + member.getExtraversion_gregariousness() + ","
							+ " agreeableness_altruism = " + member.getAgreeableness_altruism() + ","
							+ " agreeableness_cooperation = " + member.getAgreeableness_cooperation() + ","
							+ " agreeableness_modesty = " + member.getAgreeableness_modesty() + ","
							+ " agreeableness_uncompromising = " + member.getAgreeableness_uncompromising() + ","
							+ " agreeableness_sympathy = " + member.getAgreeableness_sympathy() + ","
							+ " agreeableness_trust = " + member.getAgreeableness_trust() + ","
							+ " emotional_range_fiery = " + member.getEmotional_range_fiery() + ","
							+ " emotional_range_prone_to_worry = " + member.getEmotional_range_prone_to_worry() + ","
							+ " emotional_range_melancholy = " + member.getEmotional_range_melancholy() + ","
							+ " emotional_range_immoderation = " + member.getEmotional_range_immoderation() + ","
							+ " emotional_range_self_consciousness = " + member.getEmotional_range_self_consciousness() + ","
							+ " emotional_range_susceptible_to_stress = " + member.getEmotional_range_susceptible_to_stress() + ","

							+ " top_tw_id0 = '" + member.getTop_tw_id0() + "',"
							+ " openness_tw_id0 = '" + member.getOpenness_tw_id0() + "',"
							+ " conscientiousness_tw_id0 = '" + member.getConscientiousness_tw_id0() + "',"
							+ " extraversion_tw_id0 = '" + member.getExtraversion_tw_id0() + "',"
							+ " agreeableness_tw_id0 = '" + member.getAgreeableness_tw_id0() + "',"
							+ " emotional_range_tw_id0 = '" + member.getEmotional_range_tw_id0() + "',"
							+ " top_tw_id1 = '" + member.getTop_tw_id1() + "',"
							+ " openness_tw_id1 = '" + member.getOpenness_tw_id1() + "',"
							+ " conscientiousness_tw_id1 = '" + member.getConscientiousness_tw_id1() + "',"
							+ " extraversion_tw_id1 = '" + member.getExtraversion_tw_id1() + "',"
							+ " agreeableness_tw_id1 = '" + member.getAgreeableness_tw_id1() + "',"
							+ " emotional_range_tw_id1 = '" + member.getEmotional_range_tw_id1() + "',"

							+ " updated = '" + member.getUpdated() + "'";
					sql += ( " where id = " + id );
				}else{
					//. 追加
					sql = "insert into members( id, tw_id, name,"
							+ " openness_adventurousness, openness_artistic_interests, openness_emotionality, openness_imagination, openness_intellect, openness_authority_challenging,"	
							+ " conscientiousness_achievement_striving, conscientiousness_cautiousness, conscientiousness_dutifulness, conscientiousness_orderliness, conscientiousness_self_discipline, conscientiousness_self_efficacy,"
							+ " extraversion_activity_level, extraversion_assertiveness, extraversion_cheerfulness, extraversion_excitement_seeking, extraversion_outgoing, extraversion_gregariousness,"
							+ " agreeableness_altruism, agreeableness_cooperation, agreeableness_modesty, agreeableness_uncompromising, agreeableness_sympathy, agreeableness_trust,"
							+ " emotional_range_fiery, emotional_range_prone_to_worry, emotional_range_melancholy, emotional_range_immoderation, emotional_range_self_consciousness, emotional_range_susceptible_to_stress,"
							+ " top_tw_id0, openness_tw_id0, conscientiousness_tw_id0, extraversion_tw_id0, agreeableness_tw_id0, emotional_range_tw_id0,"
							+ " top_tw_id1, openness_tw_id1, conscientiousness_tw_id1, extraversion_tw_id1, agreeableness_tw_id1, emotional_range_tw_id1,"
							+ " updated ) values( "
							+ member.getId() + ", '" + member.getTw_id() + "', '" + member.getName() + "',"
							+ member.getOpenness_adventurousness() + "," + member.getOpenness_artistic_interests() + "," + member.getOpenness_emotionality() + "," + member.getOpenness_imagination() + "," + member.getOpenness_intellect() + "," + member.getOpenness_authority_challenging() + ","
							+ member.getConscientiousness_achievement_striving() + "," + member.getConscientiousness_cautiousness() + "," + member.getConscientiousness_dutifulness() + "," + member.getConscientiousness_orderliness() + "," + member.getConscientiousness_self_discipline() + "," + member.getConscientiousness_self_efficacy() + ","
							+ member.getExtraversion_activity_level() + "," + member.getExtraversion_assertiveness() + "," + member.getExtraversion_cheerfulness() + "," + member.getExtraversion_excitement_seeking() + "," + member.getExtraversion_outgoing() + "," + member.getExtraversion_gregariousness() + ","
							+ member.getAgreeableness_altruism() + "," + member.getAgreeableness_cooperation() + "," + member.getAgreeableness_modesty() + "," + member.getAgreeableness_uncompromising() + "," + member.getAgreeableness_sympathy() + "," + member.getAgreeableness_trust() + ","
							+ member.getEmotional_range_fiery() + "," + member.getEmotional_range_prone_to_worry() + "," + member.getEmotional_range_melancholy() + "," + member.getEmotional_range_immoderation() + "," + member.getEmotional_range_self_consciousness() + "," + member.getEmotional_range_susceptible_to_stress() + ",'"
							+ member.getTop_tw_id0() + "','" + member.getOpenness_tw_id0() + "','" + member.getConscientiousness_tw_id0() + "','" + member.getExtraversion_tw_id0() + "','" + member.getAgreeableness_tw_id0() + "','" + member.getEmotional_range_tw_id0() + "','"
							+ member.getTop_tw_id1() + "','" + member.getOpenness_tw_id1() + "','" + member.getConscientiousness_tw_id1() + "','" + member.getExtraversion_tw_id1() + "','" + member.getAgreeableness_tw_id1() + "','" + member.getEmotional_range_tw_id1() + "', '"
							+ member.getUpdated() + "' )";
				}
				
				try{
					System.out.println( "sql = " + sql );
					stmt = conn.createStatement();
					r = stmt.executeUpdate( sql );
					System.out.println( " -> " + r );
					stmt.close();
				}catch( Exception e ){
					e.printStackTrace();
				}
			}
			conn.close();
		}catch( Exception e ){
			e.printStackTrace();
		}
		
		return r;
	}
	
	
	public int initTable(){
		return initTable( target_ids );
	}
	public int initTable( String[] tw_ids ){
		int cnt = 0;
		
		for( int i = 0; i < tw_ids.length; i ++ ){
			int r = updateUser( tw_ids[i] );
			if( r > 0 ){
				cnt ++;
			}
		}
		
		return cnt;
	}
	
	private Connection getConnection(){
		Connection conn = null;
		
		String dburi = "mysql://" + mysql_hostname + "/" + mysql_db + "?useUnicode=true&characterEncoding=utf8";
		
		//. 当面はこちら
		try{
			Class.forName( "com.mysql.jdbc.Driver" );
			conn = DriverManager.getConnection( "jdbc:" + dburi, mysql_username, mysql_password );
		}catch( Exception e ){
			e.printStackTrace();
		}
		
		return conn;
	}
	
	private String getBearerToken(){
		String r = null;
		
		try{
			byte[] b64data = Base64.encodeBase64( ( tw_consumer_key + ":" + tw_consumer_secret ).getBytes() );
			String body = "grant_type=client_credentials";
					
			HttpClient client = new HttpClient();
			PostMethod post = new PostMethod( "https://api.twitter.com/oauth2/token" );
			post.setRequestHeader( "Authorization", "Basic " + new String( b64data ) );
			post.setRequestHeader( "Content-Type", "application/x-www-form-urlencoded;charset=UTF-8" );
			post.setRequestBody( body );

			int sc = client.executeMethod( post );
			//System.out.println( "sc = " + sc );
			String out = post.getResponseBodyAsString();
			//System.out.println( out );

			JSONParser parser = new JSONParser();
			JSONObject obj = ( JSONObject )parser.parse( out );
			r = ( String )obj.get( "access_token" );
		}catch( Exception e ){
			e.printStackTrace();
		}

		return r;
	}
	
	public String getTweets( String tw_id ){
		String r = null;
		
		try{
			String token = getBearerToken();
			if( token != null && token.length() > 0 ){
				HttpClient client = new HttpClient();
				GetMethod get = new GetMethod( "https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=" + tw_id + "&count=200" );
				get.setRequestHeader( "Authorization", "Bearer " + token );

				int sc = client.executeMethod( get );
				//System.out.println( "sc = " + sc );
				String out = get.getResponseBodyAsString();
				//System.out.println( out );

				Long max_id = 0L;
				JSONParser parser = new JSONParser();
				JSONArray objs = ( JSONArray )parser.parse( out );
				for( int i = 0; i < objs.size(); i ++ ){
					JSONObject obj = ( JSONObject )objs.get( i );
					String text = ( String )obj.get( "text" );
					max_id = ( Long )obj.get( "id" );
					//System.out.println( "(" + i + "):" + text );
					r += text;
				}
				
				//. もう200取得
				get = new GetMethod( "https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=" + tw_id + "&count=200&max_id=" + max_id );
				get.setRequestHeader( "Authorization", "Bearer " + token );

				sc = client.executeMethod( get );
				out = get.getResponseBodyAsString();
				//System.out.println( out );

				objs = ( JSONArray )parser.parse( out );
				for( int i = 1; i < objs.size(); i ++ ){ //. i=0 はダブリ
					JSONObject obj = ( JSONObject )objs.get( i );
					String text = ( String )obj.get( "text" );
					max_id = ( Long )obj.get( "id" );
					//System.out.println( "(" + i + "):" + text );
					r += text;
				}
				
				/*
				//. 更にもう200取得
				get = new GetMethod( "https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=" + tw_id + "&count=200&max_id=" + max_id );
				get.setRequestHeader( "Authorization", "Bearer " + token );

				sc = client.executeMethod( get );
				out = get.getResponseBodyAsString();
				//System.out.println( out );
				 */

				objs = ( JSONArray )parser.parse( out );
				for( int i = 1; i < objs.size(); i ++ ){ //. i=0 はダブリ
					JSONObject obj = ( JSONObject )objs.get( i );
					String text = ( String )obj.get( "text" );
					max_id = ( Long )obj.get( "id" );
					//System.out.println( "(" + i + "):" + text );
					r += text;
				}
			}
		}catch( Exception e ){
			e.printStackTrace();
		}
		
		return r;
	}
	
	public String[] getTwitterUserInfo( String tw_id ){
		String[] r = null;
		
		try{
			String token = getBearerToken();
			if( token != null && token.length() > 0 && tw_id != null && tw_id.length() > 0 ){
				HttpClient client = new HttpClient();
				GetMethod get = new GetMethod( "https://api.twitter.com/1.1/users/show.json?screen_name=" + tw_id );
				get.setRequestHeader( "Authorization", "Bearer " + token );

				int sc = client.executeMethod( get );
				//System.out.println( "sc = " + sc );
				String out = get.getResponseBodyAsString();
				//System.out.println( out );
				
				JSONParser parser = new JSONParser();
				JSONObject obj = ( JSONObject )parser.parse( out );
				r = new String[2];
				r[0] = ( String )obj.get( "id_str" );
				//r[1] = ( String )obj.get( "screen_name" );
				r[1] = ( String )obj.get( "name" );
			}
		}catch( Exception e ){
			e.printStackTrace();
		}
		
		return r;
	}
	
	public String getCurrentDateTime(){
		String r = "";
		
		try{
			Calendar cal = Calendar.getInstance();
			SimpleDateFormat sdf = new SimpleDateFormat( "yyyy/MM/dd HH:mm:ss" );
			sdf.setTimeZone( cal.getTimeZone() );
			r = sdf.format( cal.getTime() );
		}catch( Exception e ){
		}
		
		return r;
	}
	
	public User getUserByTw_Id( String tw_id ){
		User user = null;
		
		try{
			String tweets = getTweets( tw_id );
			String[] r = getTwitterUserInfo( tw_id );
			long id = Long.parseLong( r[0] );
			String updated = getCurrentDateTime();
			
			Map<String,Double> pi = getPersonalityInsights( tweets );
			if( pi != null ){
				user = new User( id, tw_id, r[1],
						pi.get( "openness_adventurousness" ), pi.get( "openness_artistic_interests" ), pi.get( "openness_emotionality" ), pi.get( "openness_imagination" ), pi.get( "openness_intellect" ), pi.get( "openness_authority_challenging" ),
						pi.get( "conscientiousness_achievement_striving" ), pi.get( "conscientiousness_cautiousness" ), pi.get( "conscientiousness_dutifulness" ), pi.get( "conscientiousness_orderliness" ), pi.get( "conscientiousness_self_discipline" ), pi.get( "conscientiousness_self_efficacy" ), 
						pi.get( "extraversion_activity_level" ), pi.get( "extraversion_assertiveness" ), pi.get( "extraversion_cheerfulness" ), pi.get( "extraversion_excitement_seeking" ), pi.get( "extraversion_outgoing" ), pi.get( "extraversion_gregariousness" ), 
						pi.get( "agreeableness_altruism" ), pi.get( "agreeableness_cooperation" ), pi.get( "agreeableness_modesty" ), pi.get( "agreeableness_uncompromising" ), pi.get( "agreeableness_sympathy" ), pi.get( "agreeableness_trust" ), 
						pi.get( "emotional_range_fiery" ), pi.get( "emotional_range_prone_to_worry" ), pi.get( "emotional_range_melancholy" ), pi.get( "emotional_range_immoderation" ), pi.get( "emotional_range_self_consciousness" ), pi.get( "emotional_range_susceptible_to_stress" ),
						updated );
			}
		}catch( Exception e ){
			e.printStackTrace();
		}
		
		return user;
	}
	
	public Map<String,Double> getPersonalityInsights( String body ){
		Map<String,Double> r = null;

		try{
			org.apache.commons.httpclient.HttpClient client = new org.apache.commons.httpclient.HttpClient();
			byte[] b64data = Base64.encodeBase64( ( pi_username + ":" + pi_password ).getBytes() );

			PostMethod post = new PostMethod( pi_url + "/v2/profile" );
					
			post.setRequestHeader( "Content-Language", "ja" );
					
			post.setRequestHeader( "Authorization", "Basic " + new String( b64data ) );
			post.setRequestHeader( "Content-Type", "text/plain" ); //. 必須
			post.setRequestBody( body );
					
			int sc = client.executeMethod( post );
			//System.out.println( "sc = " + sc );
			if( sc == 200 ){
				String result = post.getResponseBodyAsString();
				//System.out.println( "result = " + result );
				try{
					JSONParser parser = new JSONParser();
					JSONObject obj = ( JSONObject )parser.parse( result );

					//. エラーチェック
					String error = ( String )obj.get( "error" );
					if( error != null ){	
					}else{
						r = new HashMap<String,Double>();
						
						//. Big 5 を取り出す
						JSONObject tree = ( JSONObject )obj.get( "tree" );
						JSONArray children1_array = ( JSONArray )tree.get( "children" );
						if( children1_array != null ){
							for( int i = 0; i < children1_array.size(); i ++ ){
								JSONObject children1 = ( JSONObject )children1_array.get( i );
								String id1 = ( String )children1.get( "id" );
								if( id1.equals( "personality" ) ){ //. Big 5
									String name1 = ( String )children1.get( "name" );
//									double percentage1 = ( Double )children1.get( "percentage" );
//									double sampling_error1 = ( Double )children1.get( "sampling_error" );
									JSONArray children2_array = ( JSONArray )children1.get( "children" );
									for( int j = 0; j < children2_array.size(); j ++ ){ //. children2_array.size() == 1
										JSONObject children2 = ( JSONObject )children2_array.get( j );
//										String id2 = ( String )children2.get( "id" );
//										String name2 = ( String )children2.get( "name" );
//										double percentage2 = ( Double )children2.get( "percentage" );
//										double sampling_error2 = ( Double )children2.get( "sampling_error" );
//										System.out.println( "id = " + id2 + "(" + name2 + "): " + percentage2 + "%" );
										JSONArray children3_array = ( JSONArray )children2.get( "children" );
										for( int k = 0; k < children3_array.size(); k ++ ){
											JSONObject children3 = ( JSONObject )children3_array.get( k );
//											String id3 = ( String )children3.get( "id" );
											String name3 = ( String )children3.get( "name" );
											name3 = name3.toLowerCase();
											name3 = name3.replaceAll( " ", "_" );
											name3 = name3.replaceAll( "-", "_" );
//											double percentage3 = ( Double )children3.get( "percentage" );
//											double sampling_error3 = ( Double )children3.get( "sampling_error" );
//											System.out.println( " id = " + id3 + "(" + name3 + "): " + percentage3 + "%(" + sampling_error3 + ")" );
											JSONArray children4_array = ( JSONArray )children3.get( "children" );
											for( int l = 0; l < children4_array.size(); l ++ ){
												JSONObject children4 = ( JSONObject )children4_array.get( l );
//												String id4 = ( String )children4.get( "id" );
												String name4 = ( String )children4.get( "name" );
												double percentage4 = ( Double )children4.get( "percentage" );
//												double sampling_error4 = ( Double )children4.get( "sampling_error" );
//												System.out.println( "  id = " + id4 + "(" + name4 + "): " + percentage4 + "%(" + sampling_error4 + ")" );
												name4 = name4.toLowerCase();
												name4 = name4.replaceAll( " ", "_" );
												name4 = name4.replaceAll( "-", "_" );
												
												String key = name3 + "_" + name4;
												Double value = percentage4;
												r.put( key, value );
											}
										}
									}
								}
							}
						}
					}
				}catch( Exception e ){
					e.printStackTrace();
				}
			}else{
				String result = post.getResponseBodyAsString();
				System.out.println( "Error result = " + result );
			}
		}catch( Exception e ){
			e.printStackTrace();
		}

		return r;
	}
	
	public double[] compareByCategory( User user1, User user2 ){
		double[] r = null;
		
		try{
			if( user1 != null && user2 != null ){
				r = new double[6];
				
				//. openness
				r[0] = ( user1.getOpenness_adventurousness() - user2.getOpenness_adventurousness() ) * ( user1.getOpenness_adventurousness() - user2.getOpenness_adventurousness() )
						+ ( user1.getOpenness_artistic_interests() - user2.getOpenness_artistic_interests() ) * ( user1.getOpenness_artistic_interests() - user2.getOpenness_artistic_interests() )
						+ ( user1.getOpenness_authority_challenging() - user2.getOpenness_authority_challenging() ) * ( user1.getOpenness_authority_challenging() - user2.getOpenness_authority_challenging() )
						+ ( user1.getOpenness_emotionality() - user2.getOpenness_emotionality() ) * ( user1.getOpenness_emotionality() - user2.getOpenness_emotionality() )
						+ ( user1.getOpenness_imagination() - user2.getOpenness_imagination() ) * ( user1.getOpenness_imagination() - user2.getOpenness_imagination() )
						+ ( user1.getOpenness_intellect() - user2.getOpenness_intellect() ) * ( user1.getOpenness_intellect() - user2.getOpenness_intellect() );
				
				//. conscientiousness
				r[1] = ( user1.getConscientiousness_achievement_striving() - user2.getConscientiousness_achievement_striving() ) * ( user1.getConscientiousness_achievement_striving() - user2.getConscientiousness_achievement_striving() )
						+ ( user1.getConscientiousness_cautiousness() - user2.getConscientiousness_cautiousness() ) * ( user1.getConscientiousness_cautiousness() - user2.getConscientiousness_cautiousness() )
						+ ( user1.getConscientiousness_dutifulness() - user2.getConscientiousness_dutifulness() ) * ( user1.getConscientiousness_dutifulness() - user2.getConscientiousness_dutifulness() )
						+ ( user1.getConscientiousness_orderliness() - user2.getConscientiousness_orderliness() ) * ( user1.getConscientiousness_orderliness() - user2.getConscientiousness_orderliness() )
						+ ( user1.getConscientiousness_self_discipline() - user2.getConscientiousness_self_discipline() ) * ( user1.getConscientiousness_self_discipline() - user2.getConscientiousness_self_discipline() )
						+ ( user1.getConscientiousness_self_efficacy() - user2.getConscientiousness_self_efficacy() ) * ( user1.getConscientiousness_self_efficacy() - user2.getConscientiousness_self_efficacy() );
				
				//. extraversion
				r[2] = ( user1.getExtraversion_activity_level() - user2.getExtraversion_activity_level() ) * ( user1.getExtraversion_activity_level() - user2.getExtraversion_activity_level() )
						+ ( user1.getExtraversion_assertiveness() - user2.getExtraversion_assertiveness() ) * ( user1.getExtraversion_assertiveness() - user2.getExtraversion_assertiveness() )
						+ ( user1.getExtraversion_cheerfulness() - user2.getExtraversion_cheerfulness() ) * ( user1.getExtraversion_cheerfulness() - user2.getExtraversion_cheerfulness() )
						+ ( user1.getExtraversion_excitement_seeking() - user2.getExtraversion_excitement_seeking() ) * ( user1.getExtraversion_excitement_seeking() - user2.getExtraversion_excitement_seeking() )
						+ ( user1.getExtraversion_gregariousness() - user2.getExtraversion_gregariousness() ) * ( user1.getExtraversion_gregariousness() - user2.getExtraversion_gregariousness() )
						+ ( user1.getExtraversion_outgoing() - user2.getExtraversion_outgoing() ) * ( user1.getExtraversion_outgoing() - user2.getExtraversion_outgoing() );
				
				//. agreeableness
				r[3] = ( user1.getAgreeableness_altruism() - user2.getAgreeableness_altruism() ) * ( user1.getAgreeableness_altruism() - user2.getAgreeableness_altruism() )
						+ ( user1.getAgreeableness_cooperation() - user2.getAgreeableness_cooperation() ) * ( user1.getAgreeableness_cooperation() - user2.getAgreeableness_cooperation() )
						+ ( user1.getAgreeableness_modesty() - user2.getAgreeableness_modesty() ) * ( user1.getAgreeableness_modesty() - user2.getAgreeableness_modesty() )
						+ ( user1.getAgreeableness_sympathy() - user2.getAgreeableness_sympathy() ) * ( user1.getAgreeableness_sympathy() - user2.getAgreeableness_sympathy() )
						+ ( user1.getAgreeableness_trust() - user2.getAgreeableness_trust() ) * ( user1.getAgreeableness_trust() - user2.getAgreeableness_trust() )
						+ ( user1.getAgreeableness_uncompromising() - user2.getAgreeableness_uncompromising() ) * ( user1.getAgreeableness_uncompromising() - user2.getAgreeableness_uncompromising() );
				
				//. emotional_range
				r[4] = ( user1.getEmotional_range_fiery() - user2.getEmotional_range_fiery() ) * ( user1.getEmotional_range_fiery() - user2.getEmotional_range_fiery() )
						+ ( user1.getEmotional_range_immoderation() - user2.getEmotional_range_immoderation() ) * ( user1.getEmotional_range_immoderation() - user2.getEmotional_range_immoderation() )
						+ ( user1.getEmotional_range_melancholy() - user2.getEmotional_range_melancholy() ) * ( user1.getEmotional_range_melancholy() - user2.getEmotional_range_melancholy() )
						+ ( user1.getEmotional_range_prone_to_worry() - user2.getEmotional_range_prone_to_worry() ) * ( user1.getEmotional_range_prone_to_worry() - user2.getEmotional_range_prone_to_worry() )
						+ ( user1.getEmotional_range_self_consciousness() - user2.getEmotional_range_self_consciousness() ) * ( user1.getEmotional_range_self_consciousness() - user2.getEmotional_range_self_consciousness() )
						+ ( user1.getEmotional_range_susceptible_to_stress() - user2.getEmotional_range_susceptible_to_stress() ) * ( user1.getEmotional_range_susceptible_to_stress() - user2.getEmotional_range_susceptible_to_stress() );
				
				//. All
				r[5] = r[0] + r[1] + r[2] + r[3] + r[4];
			} 
		}catch( Exception e ){
			e.printStackTrace();
		}
		
		return r;
	}
	
	public String getProfileImageURL( String tw_id ){
		String url = null;
		if( tw_id != null && tw_id.length() > 0 ){
			url = "http://www.paper-glasses.com/api/twipi/" + tw_id + "/original";
		}
		
		return url;
	}
	
	public MemcachedClient getMemcachedClient(){
		MemcachedClient mc = null;
		
		try{
			PlainCallbackHandler ph = new PlainCallbackHandler( mm_username, mm_password );
			AuthDescriptor ad = new AuthDescriptor( new String[] { "PLAIN" }, ph );
            mc = new MemcachedClient(
	            	new ConnectionFactoryBuilder()
	                	.setProtocol(ConnectionFactoryBuilder.Protocol.BINARY)
	                	.setAuthDescriptor( ad ).build(),
	                	AddrUtil.getAddresses( mm_server + ":" + mm_port ) );
		}catch( Exception e ){
			e.printStackTrace();
		}
		
		return mc;
	}
	
	public User[] resetAllMMUsers(){
		try{
			MemcachedClient mc = getMemcachedClient();
			if( mc != null ){
				mc.delete( mm_keyname );
	        }
		}catch( Exception e ){
			e.printStackTrace();
		}
		
		return getAllMMUsers( true );
	}
	
	public User[] getAllMMUsers(){
		return getAllMMUsers( false );
	}
	public User[] getAllMMUsers( boolean reset ){
		User[] users = null;
		Map<String,User> r = null;

		try{
			//. memcached から取得
			MemcachedClient mc = getMemcachedClient();
			if( mc != null ){
				List<User> list = new ArrayList<User>();
				r = ( Map<String,User> )mc.get( mm_keyname );
				if( reset || r == null || r.size() == 0 ){
					r = new HashMap<String,User>();
				
					//. MySQL から取得
					try{
						User[] users0 = getAllUsers();
						for( int i = 0; i < users0.length; i ++ ){
							User user = users0[i];
//							String key = user.getTw_id();
							String key = "" + user.getId();
							r.put( key, user );
							list.add( user );
						}
					}catch( Exception e ){
						e.printStackTrace();
					}
				}else{
					for( Map.Entry<String, User>m : r.entrySet() ){
						//String key = m.getKey();
						User user = m.getValue();
						list.add( user );
					}
				}
				
				//. memcached へ保存
				if( reset ){
					mc.delete( mm_keyname );
				}
				mc.set( mm_keyname, 0, r );
				
				users = ( User[] )list.toArray( new User[0] );
			}
		}catch( Exception e ){
			e.printStackTrace();
		}
		
		return users;
	}

	public User getMMUser( String id ){
		User user = null;

		try{
			//. memcached から取得
			MemcachedClient mc = getMemcachedClient();
			if( mc != null ){
				Map<String,User>r = ( Map<String,User> )mc.get( mm_keyname );
				if( r != null && r.size() > 0 ){
					user = r.get( id );
				}
			}
		}catch( Exception e ){
			e.printStackTrace();
		}

		return user;
	}
}
