import net from 'node:net';

export interface LegacyStatus {
  protocolVersion: number;
  version: string;
  motd: string;
  playersOnline: number;
  playersMax: number;
}

// Server list ping used by Minecraft 1.4–1.6. The client sends 0xFE 0x01;
// the server answers with a kick packet (0xFF), a big-endian u16 length in
// characters, and a UTF-16BE string:
//   "§1\0<protocol>\0<version>\0<motd>\0<online>\0<max>"
// Pre-1.4 servers ignore the 0x01 and reply with "<motd>§<online>§<max>".
export function pingLegacy(host: string, port: number, timeoutMs = 5000): Promise<LegacyStatus> {
  return new Promise((resolve, reject) => {
    const socket = net.createConnection({ host, port });
    let buffer = Buffer.alloc(0);

    const fail = (error: Error) => {
      socket.destroy();
      reject(error);
    };

    socket.setTimeout(timeoutMs, () => fail(new Error(`Ping to ${host}:${port} timed out`)));
    socket.on('error', fail);
    socket.on('connect', () => socket.write(Buffer.from([0xfe, 0x01])));

    socket.on('data', (chunk) => {
      buffer = Buffer.concat([buffer, chunk]);
      if (buffer.length < 3) return;

      if (buffer[0] !== 0xff) {
        fail(new Error(`Unexpected packet 0x${buffer[0].toString(16)}`));
        return;
      }

      const end = 3 + buffer.readUInt16BE(1) * 2;
      if (buffer.length < end) return;

      socket.end();
      try {
        resolve(parseResponse(decodeUtf16be(buffer.subarray(3, end))));
      } catch (error) {
        reject(error);
      }
    });

    socket.on('end', () => fail(new Error('Connection closed before a full response')));
  });
}

function decodeUtf16be(bytes: Buffer): string {
  // Node only decodes UTF-16LE, so swap each byte pair first.
  return Buffer.from(bytes).swap16().toString('utf16le');
}

function parseResponse(text: string): LegacyStatus {
  if (text.startsWith('§1\0')) {
    const [, protocol, version, motd, online, max] = text.split('\0');
    return {
      protocolVersion: Number(protocol),
      version,
      motd,
      playersOnline: Number(online),
      playersMax: Number(max),
    };
  }

  const parts = text.split('§');
  if (parts.length < 3) throw new Error('Unrecognized ping response');
  const max = parts.pop()!;
  const online = parts.pop()!;
  return {
    protocolVersion: 0,
    version: '',
    motd: parts.join('§'),
    playersOnline: Number(online),
    playersMax: Number(max),
  };
}
