export function isAuth(): boolean {
  return Boolean(localStorage.getItem('master-key'));
}

export function auth(password: string): void {
  localStorage.setItem('master-key', password);
  location.reload();
}
