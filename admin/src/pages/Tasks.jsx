import { useEffect, useState } from "react";
import api from "../services/api";
import Layout from "../components/Layout";

const Tasks = () => {
  const [tasks, setTasks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const fetchTasks = async () => {
      try {
        const res = await api.get("/admin/tasks");
        setTasks(res.data.data || res.data.tasks || []);
      } catch (err) {
        setError(err.response?.data?.error || "Failed to fetch tasks");
      } finally {
        setLoading(false);
      }
    };
    fetchTasks();
  }, []);

  const statusClass = (status) => {
    if (!status) return "badge";
    const s = status.toLowerCase();
    if (s.includes("complete")) return "badge status-completed";
    if (s.includes("overdue")) return "badge status-overdue";
    if (s.includes("pending")) return "badge status-pending";
    return "badge";
  };

  return (
    <Layout>
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-2xl font-semibold text-white">Tasks</h2>
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
                <th className="text-left px-4 py-3">Status</th>
                <th className="text-left px-4 py-3">Due</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800">
              {tasks.map((task) => (
                <tr key={task._id} className="hover:bg-slate-800/40">
                  <td className="px-4 py-3 text-white">{task.title}</td>
                  <td className="px-4 py-3 text-slate-200">
                    {task.userId?.email || "-"}
                  </td>
                  <td className="px-4 py-3">
                    <span className={statusClass(task.status)}>
                      {task.status || "-"}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-slate-200">
                    {task.dueDate
                      ? new Date(task.dueDate).toLocaleDateString()
                      : "-"}
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

export default Tasks;
