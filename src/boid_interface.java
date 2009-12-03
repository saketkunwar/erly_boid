/*@author saket kunwar
*@copyright saket kunwar august 2009
* Created: august 2009
* Description: TODO: 
*/



import java.util.ArrayList;
import com.ericsson.otp.erlang.*;




public class boid_interface implements Runnable{
		
		public b boid;
		public ArrayList<b> boids;
		public boolean received_data=false;
		public boid_interface(){
			
		}
	    public void run(){
	    	try{
	    	    	getc();
	    	    		}
	    	  catch (Exception e){
	    		  System.out.println(e);
	    	    			}
	 
	    }
		public void getc() throws Exception{
	    	
	        OtpNode self = new OtpNode("echonode@UKKUNWAR");
	        OtpMbox mbox = self.createMbox("echoservice");
	        OtpErlangObject o;
	        OtpErlangTuple msg;
	        OtpErlangPid from;

	        while (true) {
	            try {
	            	
	                o = mbox.receive();
	                OtpErlangTuple ms=(OtpErlangTuple) o;
	                OtpErlangTuple tu= (OtpErlangTuple) ms.elementAt(1);
	             
	                boids=parse(tu);
	                System.out.println("Received erlang pumped data");
	              
	            }
	            catch (Exception e) {
	            	
	                System.out.println("" + e);
	            }
	        }
	    }
		public ArrayList parse(OtpErlangTuple tu){
			received_data=true;
			ArrayList<b> bb=new ArrayList();
			int i=0;
			while (tu.elementAt(i)!=null)
			{	
			OtpErlangTuple tc=(OtpErlangTuple)tu.elementAt(i);
			
			//from = (OtpErlangPid)
			double x= ((OtpErlangDouble)tc.elementAt(0)).doubleValue();
            double y= ((OtpErlangDouble)tc.elementAt(1)).doubleValue();
            double vx= ((OtpErlangDouble)tc.elementAt(2)).doubleValue();
            double vy= ((OtpErlangDouble)tc.elementAt(3)).doubleValue();
            
            b boid=new b(x,y,vx,vy);
            bb.add(boid);
            i=i+1;
			}
			return bb;
		}
	}
	 
