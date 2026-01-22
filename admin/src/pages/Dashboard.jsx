import { useEffect, useState } from "react";
import api from "../services/api";
import Layout from "../components/Layout";
import { PieChart, Pie, Cell, Tooltip, ResponsiveContainer } from "recharts";

const COLORS = ["#22c55e", "#f59e0b", "#3b82f6", "#ef4444"];

const Dashboard = () => {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const res = await api.get("/admin/dashboard/stats");
        setStats(res.data.data || res.data.stats || {});
      } catch (err) {
        setError(err.response?.data?.error || "Failed to load dashboard data");
      } finally {
        setLoading(false);
      }
    };
    fetchStats();
  }, []);

  const chartData = [
    { name: "Completed", value: stats?.completedTasks || 0 },
    { name: "Pending", value: stats?.pendingTasks || 0 },
    { name: "In Progress", value: stats?.inProgressTasks || 0 },
    { name: "Overdue", value: stats?.overdueTasks || 0 },
  ];

  return (
    <Layout>
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-2xl font-semibold text-white">Dashboard</h2>
      </div>
      {loading && <div>Loading...</div>}
      {error && <div className="error">{error}</div>}
      {stats && (
        <>
          <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
            {[
              {
                label: "Total Users",
                value: stats.totalUsers || 0,
              },
              {
                label: "Total Tasks",
                value: stats.totalTasks || 0,
              },
              {
                label: "Completed Tasks",
                value: stats.completedTasks || 0,
              },
              {
                label: "Overdue Tasks",
                value: stats.overdueTasks || 0,
              },
              {
                label: "Notifications",
                value: stats.totalNotifications || 0,
              },
              {
                label: "Categories",
                value: stats.totalCategories || 0,
              },
            ].map((card) => (
              <div
                key={card.label}
                className="bg-slate-900 border border-slate-800 rounded-xl p-4 shadow"
              >
                <p className="text-sm text-slate-400 mb-1">{card.label}</p>
                <div className="text-3xl font-bold text-white">
                  {card.value}
                </div>
              </div>
            ))}
          </div>

          <div className="bg-slate-900 border border-slate-800 rounded-xl p-4 shadow mt-6">
            <h3 className="text-sm text-slate-300 mb-3">
              Task Status Distribution
            </h3>
            <div className="w-full h-[260px]">
              <ResponsiveContainer>
                <PieChart>
                  <Pie
                    data={chartData}
                    dataKey="value"
                    nameKey="name"
                    outerRadius={90}
                    label
                  >
                    {chartData.map((entry, index) => (
                      <Cell
                        key={entry.name}
                        fill={COLORS[index % COLORS.length]}
                      />
                    ))}
                  </Pie>
                  <Tooltip
                    contentStyle={{
                      background: "#0f172a",
                      border: "1px solid #1e293b",
                      color: "#e2e8f0",
                    }}
                  />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </div>
        </>
      )}
    </Layout>
  );
};

export default Dashboard;
