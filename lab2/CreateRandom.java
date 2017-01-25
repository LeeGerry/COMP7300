package lab2;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.Random;

public class CreateRandom {
	public static void main(String[] args) {
		generateTrace2(1000000);
	}

	private static String toSixteen(String in) {
		while (in.length() < 16) {
			in = "0" + in;
		}
		return in;
	}

	private static void generateTrace2(int size) {
		try {
			FileWriter fw = new FileWriter("data1.txt");
			PrintWriter pw = new PrintWriter(fw);
			ArrayList<String> memoryAccesses = new ArrayList<String>();
			Random rand = new Random();
			for (int i = 0; i < size;) {
				int low = rand.nextInt((int) Math.pow(2, 16));
				String lowS = toSixteen(Integer.toBinaryString(low));

				int high = rand.nextInt((int) Math.pow(2, 16));
				String highS = toSixteen(Integer.toBinaryString(high));

				StringBuilder sb = new StringBuilder();
				sb.append(lowS).append(highS);
				int repeat = rand.nextInt(20);
				for (int j = 0; j < repeat && i < size; j++, i++) {
					memoryAccesses.add(sb.toString());
				}
			}
			Collections.shuffle(memoryAccesses);
			Iterator<String> it = memoryAccesses.iterator();
			while (it.hasNext()) {
				pw.println(it.next());
			}
			pw.println("Z");
			pw.flush();
			pw.close();
			fw.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
