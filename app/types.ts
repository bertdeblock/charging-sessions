export type Session = {
  id: string;
  start: string;
  end: string;
  totalKwh: number;
};

export type SessionsData = { sessions: Session[] };
