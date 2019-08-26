package my.com.mandrill.base.reporting.crypto;

public class HexBinaryAdapter {

	private HexBinaryAdapter() {
	}

	private static final byte[] ENCODE_MAP = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd',
			'e', 'f' };

	private static final byte[] DECODE_MAP = {

			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 00 - 0F

			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 10 - 1F

			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 20 - 2F
			// '0' '1' '2' '3' '4' '5' '6' '7' '8' '9'
			0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 0, 0, 0, 0, 0, // 30 - 3F
			// 'A' 'B' 'C' 'D' 'E' 'F'
			0, 10, 11, 12, 13, 14, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 40 - 4F

			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 50 - 5F
			// 'a' 'b' 'c' 'd' 'e' 'f'
			0, 10, 11, 12, 13, 14, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 60 - 6F

			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 // 70 - 7F
	};

	/**
	 * Convert the specified data into a hex string.
	 * 
	 * @param data
	 *            The data to encode.
	 * @return The hex encoding.
	 */
	public static byte[] encode(byte[] data) {

		if (null == data || 0 == data.length) {
			return data;
		}

		byte[] encoded = new byte[data.length * 2];

		for (int i = 0, j = 0; i < data.length; i++, j += 2) {
			encoded[j] = ENCODE_MAP[(data[i] >> 4) & 0xF];
			encoded[j + 1] = ENCODE_MAP[data[i] & 0xF];
		}

		return encoded;
	}

	/**
	 * Decode the specified hex encoded string.
	 * 
	 * @param string
	 *            The encoded string.
	 * @return The decoded data.
	 */
	public static byte[] decode(byte[] data) {

		if (null == data || 0 == data.length) {
			return data;
		}

		byte[] decoded = new byte[data.length / 2];

		for (int i = 0, j = 0; i < decoded.length; i++, j = i * 2) {
			decoded[i] = (byte) (DECODE_MAP[data[j]] << 4 | DECODE_MAP[data[j + 1]]);
		}

		return decoded;
	}
}
