import { useEffect, useState } from "react";
import api from "../services/api";
import Layout from "../components/Layout";

const Notifications = () => {
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const fetchNotifications = async () => {
      try {
        const res = await api.get("/admin/notifications");
        setNotifications(res.data.data || res.data.notifications || []);
      } catch (err) {
        setError(err.response?.data?.error || "Failed to fetch notifications");
      } finally {
        setLoading(false);
      }
    };
    fetchNotifications();
  }, []);

  return (
    <Layout>
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-2xl font-semibold text-white">Notifications</h2>
      </div>
      {loading && <div>Loading...</div>}
      {error && <div className="error">{error}</div>}
      {!loading && !error && (
        <div className="bg-slate-900 border border-slate-800 rounded-xl shadow">
          <table className="w-full border-collapse text-sm">
            <thead className="bg-slate-800/50 text-slate-300">
              <tr>
                <th className="text-left px-4 py-3">Title</th>
                <th className="text-left px-4 py-3">User</th>
                <th className="text-left px-4 py-3">Created</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800">
              {notifications.map((n) => (
                <tr key={n._id} className="hover:bg-slate-800/40">
                  <td className="px-4 py-3 text-white">
                    {n.title || n.message || "Notification"}
                  </td>
                  <td className="px-4 py-3 text-slate-200">
                    {n.userId?.email || "-"}
                  </td>
                  <td className="px-4 py-3 text-slate-300">
                    {new Date(n.createdAt).toLocaleString()}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </Layout>
  );
};

export default Notifications;
