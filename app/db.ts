import type { Session, SessionsData } from 'ev/types';

const endpoint = 'https://api.jsonbin.io/v3/b/67c2d74fe41b4d34e49ec918';
const headers = {
  'Content-Type': 'application/json',
  'X-Master-Key': localStorage.getItem('master-key') ?? '',
};

export async function readSessions(): Promise<SessionsData> {
  const storedSessions = localStorage.getItem('sessions');

  if (storedSessions) {
    return JSON.parse(storedSessions) as SessionsData;
  }

  const response = await fetch(endpoint, { headers });

  let sessionsData: SessionsData;

  if (response.ok) {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
    sessionsData = (await response.json()).record as SessionsData;
  } else {
    sessionsData = { sessions: [] };
  }

  localStorage.setItem('sessions', JSON.stringify(sessionsData));

  return sessionsData;
}

export async function createSession(session: Session): Promise<void> {
  const { sessions } = await readSessions();
  const sessionsData: SessionsData = { sessions: [session, ...sessions] };
  const sessionsJson = JSON.stringify(sessionsData);

  const response = await fetch(endpoint, {
    body: sessionsJson,
    headers,
    method: 'PUT',
  });

  if (response.ok) {
    localStorage.setItem('sessions', sessionsJson);
  }
}

export async function deleteSession(session: Session): Promise<void> {
  if (confirm(`Sessie "${session.id}" verwijderen?`) === false) {
    return;
  }

  const { sessions } = await readSessions();
  const sessionsData: SessionsData = {
    sessions: sessions.filter((s) => s.id !== session.id),
  };
  const sessionsJson = JSON.stringify(sessionsData);

  await fetch(endpoint, {
    body: sessionsJson,
    headers,
    method: 'PUT',
  });

  localStorage.setItem('sessions', sessionsJson);
  location.reload();
}

export function clearStorage(): void {
  localStorage.removeItem('sessions');
  location.reload();
}
