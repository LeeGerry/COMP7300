package lab3;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class GenerateRandomFile2 {
	final static int STATE_OLD = 0;
	static final int STATE_NEW = 1;
	static final int BOUND = (int) (Math.pow(2, 30) - 1);
	static List<Integer> q = new ArrayList<>(); // pool size 12
	static int currentState;
	static ArrayList<Integer> result = new ArrayList<>();
	static Random r = new Random();

	public static void main(String[] args) {
		int next = STATE_NEW;
		while (result.size() < 1000000) {
			currentState = next;
			int temp;
			if (currentState == STATE_NEW) {//
				// random an address
				temp = r.nextInt(BOUND);
				// update q
				q.add(temp);
				if (q.size() > 12)
					q.remove(0);
				result.add(temp);
			} else {// old
					// pick up an address from q
				int index;
				if(q.size()<12)
					index = r.nextInt(q.size());
				else
					index = r.nextInt(12);
				temp = q.get(index);
				// update q
				q.remove(index);
				q.add(temp);
			}
			int count = r.nextInt(512);
			for (int i = 0; i < count; i++) {
				int address = temp + i;
				if (address <= BOUND) {
					result.add(address);
				}
			}
			next = getNextState(currentState);
		}
		System.out.println(result.size());
		FileWriter fw = null;
		PrintWriter pw = null;
		try {
			fw = new FileWriter("data.txt");
			pw = new PrintWriter(fw);
			for (int i = 0; i < 1000001; i++) {
				StringBuilder s = new StringBuilder(Integer.toBinaryString(result.get(i)));
				while (s.length() < 30) {
					s.insert(0, "0");
				}
				pw.println(s.toString());
			}
		} catch (Exception e) {
			
		}finally{
			try {
				fw.close();
				pw.close();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
	}

	private static int getNextState(int current) {
		int temp = r.nextInt(10);
		if (current == STATE_NEW) {
			if (temp < 2) {
				return STATE_NEW;
			} else {
				return STATE_OLD;
			}
		} else {
			if (temp < 1)
				return STATE_NEW;
			else
				return STATE_OLD;
		}

	}
}
