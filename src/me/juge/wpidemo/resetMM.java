package me.juge.wpidemo;



public class resetMM {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		App app = new App();
		User[] users = app.resetAllMMUsers();		
		for( int i = 0; i < users.length; i ++ ){
			User user = users[i];

			System.out.println( user.getTw_id() + ":" + user.getName() );
		}
	}

}
