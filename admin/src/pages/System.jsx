import { useEffect, useState } from "react";
import api from "../services/api";
import Layout from "../components/Layout";

const System = () => {
  const [info, setInfo] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const fetchInfo = async () => {
      try {
        const res = await api.get("/admin/system/info");
        setInfo(res.data.data || res.data.systemInfo || {});
      } catch (err) {
        setError(err.response?.data?.error || "Failed to fetch system info");
      } finally {
        setLoading(false);
      }
    };
    fetchInfo();
  }, []);

  return (
    <Layout>
      <h2 className="page-title">System</h2>
      {loading && <div>Loading...</div>}
      {error && <div className="error">{error}</div>}
      {info && (
        <div className="card">
          <div style={{ display: "grid", gap: 8 }}>
            <div>
              <strong>Database:</strong> {info.database?.name || "-"}
            </div>
            <div>
              <strong>Collections:</strong> {info.database?.collections || "-"}
            </div>
            <div>
              <strong>Data Size:</strong> {info.database?.dataSize || "-"}
            </div>
            <div>
              <strong>Index Size:</strong> {info.database?.indexSize || "-"}
            </div>
            <div>
              <strong>Node Version:</strong> {info.server?.nodeVersion || "-"}
            </div>
            <div>
              <strong>Platform:</strong> {info.server?.platform || "-"}
            </div>
            <div>
              <strong>Uptime (s):</strong>{" "}
              {Math.round(info.server?.uptime || 0)}
            </div>
          </div>
        </div>
      )}
    </Layout>
  );
};

export default System;
