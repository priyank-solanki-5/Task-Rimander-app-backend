import { useEffect, useState } from "react";
import api from "../services/api";
import Layout from "../components/Layout";

const Documents = () => {
  const [documents, setDocuments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    fetchDocuments();
  }, []);

  const fetchDocuments = async () => {
    try {
      setLoading(true);
      const res = await api.get("/admin/documents");
      setDocuments(res.data.data || []);
      setError("");
    } catch (err) {
      setError(err.response?.data?.error || "Failed to fetch documents");
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Are you sure you want to delete this document?")) {
      return;
    }

    try {
      await api.delete(`/admin/documents/${id}`);
      setDocuments(documents.filter((doc) => doc._id !== id));
    } catch (err) {
      alert(err.response?.data?.error || "Failed to delete document");
    }
  };

  const formatFileSize = (bytes) => {
    if (bytes === 0) return "0 Bytes";
    const k = 1024;
    const sizes = ["Bytes", "KB", "MB", "GB"];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round((bytes / Math.pow(k, i)) * 100) / 100 + " " + sizes[i];
  };

  const getFileIcon = (mimeType) => {
    if (mimeType.startsWith("image/")) {
      return (
        <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
          <path
            fillRule="evenodd"
            d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z"
            clipRule="evenodd"
          />
        </svg>
      );
    } else if (mimeType.includes("pdf")) {
      return (
        <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
          <path
            fillRule="evenodd"
            d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z"
            clipRule="evenodd"
          />
        </svg>
      );
    } else if (mimeType.includes("word") || mimeType.includes("document")) {
      return (
        <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
          <path d="M9 2a2 2 0 00-2 2v8a2 2 0 002 2h6a2 2 0 002-2V6.414A2 2 0 0016.414 5L14 2.586A2 2 0 0012.586 2H9z" />
        </svg>
      );
    }
    return (
      <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
        <path
          fillRule="evenodd"
          d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4zm2 6a1 1 0 011-1h6a1 1 0 110 2H7a1 1 0 01-1-1zm1 3a1 1 0 100 2h6a1 1 0 100-2H7z"
          clipRule="evenodd"
        />
      </svg>
    );
  };

  return (
    <Layout>
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-2xl font-semibold text-white">Documents</h2>
        <div className="text-sm text-slate-400">
          Total:{" "}
          <span className="font-semibold text-white">{documents.length}</span>
        </div>
      </div>

      {loading && (
        <div className="flex items-center justify-center py-12">
          <div className="text-slate-400">Loading documents...</div>
        </div>
      )}

      {error && (
        <div className="bg-red-500/10 border border-red-500/50 rounded-lg p-4 mb-6">
          <p className="text-red-400 text-sm">{error}</p>
        </div>
      )}

      {!loading && !error && documents.length === 0 && (
        <div className="bg-slate-900 border border-slate-800 rounded-xl p-12 text-center">
          <svg
            className="w-16 h-16 mx-auto text-slate-600 mb-4"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"
            />
          </svg>
          <p className="text-slate-400">No documents found</p>
        </div>
      )}

      {!loading && !error && documents.length > 0 && (
        <div className="bg-slate-900 border border-slate-800 rounded-xl shadow overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full border-collapse text-sm">
              <thead className="bg-slate-800/50 text-slate-300">
                <tr>
                  <th className="text-left px-4 py-3 font-semibold">File</th>
                  <th className="text-left px-4 py-3 font-semibold">Task</th>
                  <th className="text-left px-4 py-3 font-semibold">Owner</th>
                  <th className="text-left px-4 py-3 font-semibold">Size</th>
                  <th className="text-left px-4 py-3 font-semibold">Type</th>
                  <th className="text-left px-4 py-3 font-semibold">
                    Uploaded
                  </th>
                  <th className="text-left px-4 py-3 font-semibold">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-800">
                {documents.map((doc) => (
                  <tr
                    key={doc._id}
                    className="hover:bg-slate-800/40 transition"
                  >
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-3">
                        <div className="text-sky-400">
                          {getFileIcon(doc.mimeType)}
                        </div>
                        <div>
                          <p className="font-medium text-white truncate max-w-xs">
                            {doc.originalName}
                          </p>
                          <p className="text-xs text-slate-500 truncate max-w-xs">
                            {doc.filename}
                          </p>
                        </div>
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      {doc.taskId ? (
                        <span className="text-slate-200">
                          {doc.taskId.title}
                        </span>
                      ) : (
                        <span className="text-slate-500 italic">No task</span>
                      )}
                    </td>
                    <td className="px-4 py-3">
                      {doc.userId ? (
                        <div>
                          <p className="text-white">{doc.userId.username}</p>
                          <p className="text-xs text-slate-400">
                            {doc.userId.email}
                          </p>
                        </div>
                      ) : (
                        <span className="text-slate-500 italic">Unknown</span>
                      )}
                    </td>
                    <td className="px-4 py-3 text-slate-300">
                      {formatFileSize(doc.fileSize)}
                    </td>
                    <td className="px-4 py-3">
                      <span className="inline-flex items-center px-2 py-1 rounded-md text-xs font-medium bg-slate-700 text-slate-300">
                        {doc.mimeType.split("/")[1]?.toUpperCase() || "FILE"}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-slate-300">
                      {new Date(doc.createdAt).toLocaleDateString()}
                    </td>
                    <td className="px-4 py-3">
                      <button
                        onClick={() => handleDelete(doc._id)}
                        className="text-red-400 hover:text-red-300 transition"
                        title="Delete document"
                      >
                        <svg
                          className="w-5 h-5"
                          fill="none"
                          stroke="currentColor"
                          viewBox="0 0 24 24"
                        >
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth={2}
                            d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                          />
                        </svg>
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </Layout>
  );
};

export default Documents;
