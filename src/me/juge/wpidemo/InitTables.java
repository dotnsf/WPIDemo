package me.juge.wpidemo;


public class InitTables {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		App app = new App();
		//String[] tw_ids = { "AbeShinzo", "konotarogomame", "katayama_s" };
		int r = app.initTable();
		
		System.out.println( "r = " + r );
	}

}
