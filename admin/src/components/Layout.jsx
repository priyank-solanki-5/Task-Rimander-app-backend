import { Link, useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

const navItems = [
  { path: "/dashboard", label: "Dashboard" },
  { path: "/users", label: "Users" },
  { path: "/tasks", label: "Tasks" },
  { path: "/documents", label: "Documents" },
  { path: "/notifications", label: "Notifications" },
  { path: "/system", label: "System" },
];

const Layout = ({ children }) => {
  const location = useLocation();
  const navigate = useNavigate();
  const { logout, user } = useAuth();

  const handleLogout = () => {
    logout();
    navigate("/login");
  };

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 grid md:grid-cols-[240px_1fr]">
      <aside className="bg-slate-950 border-r border-slate-800 flex flex-col gap-4 px-4 py-6">
        <div className="font-bold text-xl text-sky-400">Admin Panel</div>
        <nav className="space-y-1">
          {navItems.map((item) => (
            <Link
              key={item.path}
              to={item.path}
              className={`block px-3 py-2 rounded-lg transition text-sm font-medium ${
                location.pathname === item.path
                  ? "bg-gradient-to-r from-blue-600 to-sky-500 text-white"
                  : "text-slate-300 hover:bg-slate-800 hover:text-white"
              }`}
            >
              {item.label}
            </Link>
          ))}
        </nav>

        {/* User Info & Logout */}
        <div className="mt-auto pt-4 border-t border-slate-800 space-y-3">
          {user && (
            <div className="bg-slate-800/50 rounded-lg p-3">
              <p className="text-xs text-slate-400">Logged in as</p>
              <p className="font-semibold text-sm text-white truncate">
                {user.username}
              </p>
              <p className="text-xs text-slate-400 truncate">{user.email}</p>
            </div>
          )}
          <button
            className="w-full bg-rose-500 hover:bg-rose-600 text-white rounded-lg px-4 py-2.5 text-sm font-semibold transition shadow-md flex items-center justify-center gap-2"
            onClick={handleLogout}
          >
            <svg
              className="w-4 h-4"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"
              />
            </svg>
            Logout
          </button>
        </div>
      </aside>
      <main className="p-6 md:p-8 bg-slate-900">{children}</main>
    </div>
  );
};

export default Layout;
