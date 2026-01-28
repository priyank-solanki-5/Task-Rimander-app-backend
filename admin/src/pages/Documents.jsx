import { useEffect, useState } from "react";
import api from "../services/api";
import Layout from "../components/Layout";

const Documents = () => {
  const [documents, setDocuments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [previewDoc, setPreviewDoc] = useState(null);
  const [showPreview, setShowPreview] = useState(false);

  const apiBase = (api.defaults.baseURL || "").replace(/\/api\/?$/, "");

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

  const formatDate = (dateString) => {
    const d = dateString ? new Date(dateString) : null;
    return d && !isNaN(d) ? d.toLocaleDateString() : "-";
  };

  const getDownloadUrl = (doc) => {
    if (!doc) return "#";

    // Prefer static uploads path (does not rely on auth headers in a new tab/iframe)
    const raw = doc.filePath || "";
    if (raw) {
      const normalized = raw.startsWith("/") ? raw.slice(1) : raw;
      // URL encode the path components to handle spaces and special characters
      const pathParts = normalized.split("/");
      const encodedPath = pathParts
        .map((part) => encodeURIComponent(part))
        .join("/");
      return `${apiBase}/${encodedPath}`;
    }

    // Fallback to auth-protected download endpoint if no stored path
    return doc._id ? `${apiBase}/api/admin/documents/${doc._id}/download` : "#";
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

  const handlePreview = (doc) => {
    setPreviewDoc(doc);
    setShowPreview(true);
  };

  const closePreview = () => {
    setShowPreview(false);
    setPreviewDoc(null);
  };

  const renderPreviewContent = () => {
    if (!previewDoc) return null;

    const url = getDownloadUrl(previewDoc);
    const mimeType = previewDoc.mimeType || "";

    // Image preview
    if (mimeType.startsWith("image/")) {
      return (
        <img
          src={url}
          alt={previewDoc.originalName}
          className="max-w-full max-h-[80vh] mx-auto rounded-lg"
        />
      );
    }

    // PDF preview
    if (mimeType.includes("pdf")) {
      return (
        <iframe
          src={url}
          className="w-full h-[80vh] rounded-lg border-0"
          title={previewDoc.originalName}
        />
      );
    }

    // Text files
    if (mimeType.startsWith("text/")) {
      return (
        <iframe
          src={url}
          className="w-full h-[80vh] rounded-lg border border-slate-700 bg-white"
          title={previewDoc.originalName}
        />
      );
    }

    // For other file types, show download option
    return (
      <div className="text-center py-12">
        <svg
          className="w-20 h-20 mx-auto text-slate-500 mb-4"
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
        <p className="text-slate-300 mb-4">
          Preview not available for this file type
        </p>
        <a
          href={url}
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center gap-2 px-4 py-2 bg-sky-600 hover:bg-sky-500 text-white rounded-lg transition"
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
              d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"
            />
          </svg>
          Download File
        </a>
      </div>
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
                          <a
                            href={getDownloadUrl(doc)}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="font-medium text-white hover:text-sky-300 truncate max-w-xs block"
                          >
                            {doc.originalName || doc.filename}
                          </a>
                          <a
                            href={getDownloadUrl(doc)}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-xs text-slate-500 hover:text-sky-300 truncate max-w-xs block"
                          >
                            {doc.filename}
                          </a>
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
                      {formatDate(doc.createdAt)}
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        <button
                          onClick={() => handlePreview(doc)}
                          className="text-sky-400 hover:text-sky-300 transition"
                          title="Preview document"
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
                              d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                            />
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth={2}
                              d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"
                            />
                          </svg>
                        </button>
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
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Preview Modal */}
      {showPreview && previewDoc && (
        <div
          className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-center justify-center p-4"
          onClick={closePreview}
        >
          <div
            className="bg-slate-900 border border-slate-700 rounded-xl shadow-2xl max-w-6xl w-full max-h-[90vh] overflow-hidden"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Modal Header */}
            <div className="flex items-center justify-between p-4 border-b border-slate-700">
              <div className="flex items-center gap-3">
                <div className="text-sky-400">
                  {getFileIcon(previewDoc.mimeType)}
                </div>
                <div>
                  <h3 className="text-lg font-semibold text-white">
                    {previewDoc.originalName || previewDoc.filename}
                  </h3>
                  <p className="text-sm text-slate-400">
                    {formatFileSize(previewDoc.fileSize)} •{" "}
                    {previewDoc.mimeType.split("/")[1]?.toUpperCase()}
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <a
                  href={getDownloadUrl(previewDoc)}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="p-2 text-slate-400 hover:text-sky-400 hover:bg-slate-800 rounded-lg transition"
                  title="Download"
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
                      d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"
                    />
                  </svg>
                </a>
                <button
                  onClick={closePreview}
                  className="p-2 text-slate-400 hover:text-white hover:bg-slate-800 rounded-lg transition"
                  title="Close"
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
                      d="M6 18L18 6M6 6l12 12"
                    />
                  </svg>
                </button>
              </div>
            </div>

            {/* Modal Body */}
            <div className="p-4 overflow-auto bg-slate-800/50">
              {renderPreviewContent()}
            </div>
          </div>
        </div>
      )}
    </Layout>
  );
};

export default Documents;
