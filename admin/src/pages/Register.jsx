import { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

const Register = () => {
  const [formData, setFormData] = useState({
    username: "",
    email: "",
    mobilenumber: "",
    password: "",
    confirmPassword: "",
    adminKey: "",
  });
  const [error, setError] = useState("");
  const [validationErrors, setValidationErrors] = useState({});
  const [successMessage, setSuccessMessage] = useState("");
  const navigate = useNavigate();
  const { register, loading } = useAuth();

  const validateForm = () => {
    const errors = {};

    if (!formData.username.trim()) {
      errors.username = "Username is required";
    } else if (formData.username.length < 3) {
      errors.username = "Username must be at least 3 characters";
    }

    if (!formData.email.trim()) {
      errors.email = "Email is required";
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      errors.email = "Invalid email format";
    }

    if (!formData.mobilenumber.trim()) {
      errors.mobilenumber = "Mobile number is required";
    } else if (!/^\d{10}$/.test(formData.mobilenumber.replace(/\D/g, ""))) {
      errors.mobilenumber = "Mobile number must be 10 digits";
    }

    if (!formData.password) {
      errors.password = "Password is required";
    } else if (formData.password.length < 6) {
      errors.password = "Password must be at least 6 characters";
    }

    if (!formData.confirmPassword) {
      errors.confirmPassword = "Please confirm your password";
    } else if (formData.password !== formData.confirmPassword) {
      errors.confirmPassword = "Passwords do not match";
    }

    if (!formData.adminKey.trim()) {
      errors.adminKey = "Admin key is required";
    }

    return errors;
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
    // Clear validation error for this field
    if (validationErrors[name]) {
      setValidationErrors((prev) => ({
        ...prev,
        [name]: "",
      }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setSuccessMessage("");
    setValidationErrors({});

    const errors = validateForm();
    if (Object.keys(errors).length > 0) {
      setValidationErrors(errors);
      return;
    }

    const result = await register(
      formData.username,
      formData.email,
      formData.mobilenumber,
      formData.password,
      formData.adminKey,
    );

    if (result.success) {
      setSuccessMessage(result.message);
      setFormData({
        username: "",
        email: "",
        mobilenumber: "",
        password: "",
        confirmPassword: "",
        adminKey: "",
      });
      setTimeout(() => {
        navigate("/login");
      }, 2000);
    } else {
      setError(result.message || "Registration failed");
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 px-4 py-8">
      <div className="w-full max-w-md">
        {/* Logo/Header */}
        <div className="text-center mb-8">
          <div className="inline-block bg-gradient-to-r from-blue-600 to-sky-500 rounded-full p-3 mb-4">
            <svg
              className="w-8 h-8 text-white"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M13 10V3L4 14h7v7l9-11h-7z"
              />
            </svg>
          </div>
          <h1 className="text-3xl font-bold text-white">Task Reminder</h1>
          <p className="text-slate-400 text-sm mt-2">Admin Dashboard</p>
        </div>

        {/* Register Form Card */}
        <form
          className="bg-slate-950 border border-slate-800 rounded-2xl p-7 shadow-2xl space-y-4"
          onSubmit={handleSubmit}
        >
          <div>
            <h2 className="text-2xl font-semibold text-white mb-1">
              Create Account
            </h2>
            <p className="text-slate-400 text-sm">
              Join us and start managing your tasks
            </p>
          </div>

          {/* Success Message */}
          {successMessage && (
            <div className="bg-green-500/10 border border-green-500/50 rounded-lg p-3">
              <p className="text-green-400 text-sm">{successMessage}</p>
            </div>
          )}

          {/* Username Input */}
          <div className="space-y-2">
            <label
              htmlFor="username"
              className="text-sm font-medium text-slate-300"
            >
              Username
            </label>
            <input
              id="username"
              type="text"
              name="username"
              value={formData.username}
              onChange={handleChange}
              placeholder="Choose a username"
              className={`w-full rounded-lg bg-slate-900 border px-4 py-2 text-slate-100 text-sm transition focus:outline-none focus:ring-2 ${
                validationErrors.username
                  ? "border-red-500 focus:ring-red-500"
                  : "border-slate-700 focus:ring-sky-500"
              }`}
            />
            {validationErrors.username && (
              <p className="text-red-400 text-xs">
                {validationErrors.username}
              </p>
            )}
          </div>

          {/* Email Input */}
          <div className="space-y-2">
            <label
              htmlFor="email"
              className="text-sm font-medium text-slate-300"
            >
              Email Address
            </label>
            <input
              id="email"
              type="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              placeholder="you@example.com"
              className={`w-full rounded-lg bg-slate-900 border px-4 py-2 text-slate-100 text-sm transition focus:outline-none focus:ring-2 ${
                validationErrors.email
                  ? "border-red-500 focus:ring-red-500"
                  : "border-slate-700 focus:ring-sky-500"
              }`}
            />
            {validationErrors.email && (
              <p className="text-red-400 text-xs">{validationErrors.email}</p>
            )}
          </div>

          {/* Mobile Number Input */}
          <div className="space-y-2">
            <label
              htmlFor="mobilenumber"
              className="text-sm font-medium text-slate-300"
            >
              Mobile Number
            </label>
            <input
              id="mobilenumber"
              type="tel"
              name="mobilenumber"
              value={formData.mobilenumber}
              onChange={handleChange}
              placeholder="+1 (555) 123-4567"
              className={`w-full rounded-lg bg-slate-900 border px-4 py-2 text-slate-100 text-sm transition focus:outline-none focus:ring-2 ${
                validationErrors.mobilenumber
                  ? "border-red-500 focus:ring-red-500"
                  : "border-slate-700 focus:ring-sky-500"
              }`}
            />
            {validationErrors.mobilenumber && (
              <p className="text-red-400 text-xs">
                {validationErrors.mobilenumber}
              </p>
            )}
          </div>

          {/* Password Input */}
          <div className="space-y-2">
            <label
              htmlFor="password"
              className="text-sm font-medium text-slate-300"
            >
              Password
            </label>
            <input
              id="password"
              type="password"
              name="password"
              value={formData.password}
              onChange={handleChange}
              placeholder="Create a strong password"
              className={`w-full rounded-lg bg-slate-900 border px-4 py-2 text-slate-100 text-sm transition focus:outline-none focus:ring-2 ${
                validationErrors.password
                  ? "border-red-500 focus:ring-red-500"
                  : "border-slate-700 focus:ring-sky-500"
              }`}
            />
            {validationErrors.password && (
              <p className="text-red-400 text-xs">
                {validationErrors.password}
              </p>
            )}
          </div>

          {/* Confirm Password Input */}
          <div className="space-y-2">
            <label
              htmlFor="confirmPassword"
              className="text-sm font-medium text-slate-300"
            >
              Confirm Password
            </label>
            <input
              id="confirmPassword"
              type="password"
              name="confirmPassword"
              value={formData.confirmPassword}
              onChange={handleChange}
              placeholder="Confirm your password"
              className={`w-full rounded-lg bg-slate-900 border px-4 py-2 text-slate-100 text-sm transition focus:outline-none focus:ring-2 ${
                validationErrors.confirmPassword
                  ? "border-red-500 focus:ring-red-500"
                  : "border-slate-700 focus:ring-sky-500"
              }`}
            />
            {validationErrors.confirmPassword && (
              <p className="text-red-400 text-xs">
                {validationErrors.confirmPassword}
              </p>
            )}
          </div>

          {/* Admin Key Input */}
          <div className="space-y-2">
            <label
              htmlFor="adminKey"
              className="text-sm font-medium text-slate-300"
            >
              Admin Key
            </label>
            <input
              id="adminKey"
              type="password"
              name="adminKey"
              value={formData.adminKey}
              onChange={handleChange}
              placeholder="Enter admin registration key"
              className={`w-full rounded-lg bg-slate-900 border px-4 py-2 text-slate-100 text-sm transition focus:outline-none focus:ring-2 ${
                validationErrors.adminKey
                  ? "border-red-500 focus:ring-red-500"
                  : "border-slate-700 focus:ring-sky-500"
              }`}
            />
            {validationErrors.adminKey && (
              <p className="text-red-400 text-xs">
                {validationErrors.adminKey}
              </p>
            )}
            <p className="text-xs text-slate-500">
              Contact administrator to get the registration key
            </p>
          </div>

          {/* Error Message */}
          {error && (
            <div className="bg-red-500/10 border border-red-500/50 rounded-lg p-3">
              <p className="text-red-400 text-sm">{error}</p>
            </div>
          )}

          {/* Submit Button */}
          <button
            type="submit"
            disabled={loading}
            className="w-full rounded-lg bg-gradient-to-r from-blue-600 to-sky-500 py-2.5 font-semibold text-white shadow-lg hover:opacity-95 disabled:opacity-60 disabled:cursor-not-allowed transition text-sm"
          >
            {loading ? "Creating Account..." : "Create Account"}
          </button>

          {/* Divider */}
          <div className="relative">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-slate-700"></div>
            </div>
            <div className="relative flex justify-center text-sm">
              <span className="px-2 bg-slate-950 text-slate-400">or</span>
            </div>
          </div>

          {/* Login Link */}
          <p className="text-center text-slate-400 text-sm">
            Already have an account?{" "}
            <Link
              to="/login"
              className="font-semibold text-sky-400 hover:text-sky-300 transition"
            >
              Sign in
            </Link>
          </p>
        </form>

        {/* Footer Text */}
        <p className="text-center text-slate-500 text-xs mt-6">
          By creating an account, you agree to our Terms of Service and Privacy
          Policy
        </p>
      </div>
    </div>
  );
};

export default Register;
