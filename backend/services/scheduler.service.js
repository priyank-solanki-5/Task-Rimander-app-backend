import cron from "node-cron";
import notificationService from "../services/notification.service.js";

/**
 * Scheduler service for handling notification jobs
 * Uses node-cron for scheduling recurring tasks
 */
class SchedulerService {
  constructor() {
    this.jobs = new Map();
  }

  /**
   * Initialize all scheduler jobs
   */
  initializeScheduler() {
    console.log("🔔 Initializing notification scheduler...");

    // Run notification check every 6 hours
    // 0 0,6,12,18 * * * (at 12am, 6am, 12pm, 6pm)
    this.scheduleNotificationCheck();

    // Run daily check for overdue tasks at 8 AM
    // 0 8 * * * (every day at 8am)
    this.scheduleDailyOverdueCheck();

    // Keep-alive job for Render (ping every 10 minutes to prevent sleep)
    this.scheduleKeepAlive();

    console.log("✅ Notification scheduler initialized successfully");
  }

  /**
   * Schedule notification check every 6 hours
   */
  scheduleNotificationCheck() {
    const jobId = "notification-check";

    // Run every 15 minutes to catch "1 hour before time" precise reminders
    const job = cron.schedule("*/15 * * * *", async () => {
      console.log(
        `\n⏰ [${new Date().toISOString()}] Running notification check...`,
      );

      try {
        const result = await notificationService.checkAndCreateNotifications();
        console.log(`✅ Notification check completed:`, result);
      } catch (error) {
        console.error(`❌ Error in notification check:`, error.message);
      }
    });

    this.jobs.set(jobId, job);
    console.log("📅 Scheduled: Notification check - every 15 minutes");
  }

  /**
   * Schedule daily overdue tasks check at 8 AM
   */
  scheduleDailyOverdueCheck() {
    const jobId = "daily-overdue-check";

    // Run every day at 8:00 AM
    const job = cron.schedule("0 8 * * *", async () => {
      console.log(
        `\n⏰ [${new Date().toISOString()}] Running daily overdue check...`,
      );

      try {
        const result = await notificationService.checkAndCreateNotifications();
        console.log(`✅ Daily overdue check completed:`, result);
      } catch (error) {
        console.error(`❌ Error in daily overdue check:`, error.message);
      }
    });

    this.jobs.set(jobId, job);
    console.log("📅 Scheduled: Daily overdue check - every day at 8 AM");
  }

  /**
   * Schedule keep-alive job for Render (prevent service from sleeping)
   * Runs every 10 minutes to keep the service active
   */
  scheduleKeepAlive() {
    const jobId = "keep-alive";

    // Run every 10 minutes to prevent Render from spinning down
    const job = cron.schedule("*/10 * * * *", async () => {
      const now = new Date().toISOString();
      console.log(`🔄 [${now}] Keep-alive ping - Service is active`);

      // You can add logic here to ping your own /health endpoint if needed
      // or just log to keep the process active
    });

    this.jobs.set(jobId, job);
    console.log(
      "📅 Scheduled: Keep-alive job - every 10 minutes (prevents Render sleep)",
    );
  }

  /**
   * Schedule a custom job
   * @param {string} jobId - Unique job identifier
   * @param {string} cronExpression - Cron expression (e.g., "0 0 * * *" for daily at midnight)
   * @param {Function} callback - Async function to execute
   */
  scheduleCustomJob(jobId, cronExpression, callback) {
    try {
      // Stop existing job if it exists
      if (this.jobs.has(jobId)) {
        this.stopJob(jobId);
      }

      const job = cron.schedule(cronExpression, async () => {
        console.log(
          `\n⏰ [${new Date().toISOString()}] Running custom job: ${jobId}`,
        );
        try {
          await callback();
          console.log(`✅ Custom job completed: ${jobId}`);
        } catch (error) {
          console.error(`❌ Error in custom job ${jobId}:`, error.message);
        }
      });

      this.jobs.set(jobId, job);
      console.log(`📅 Scheduled: ${jobId} - ${cronExpression}`);

      return { success: true, message: `Job ${jobId} scheduled successfully` };
    } catch (error) {
      console.error(`❌ Error scheduling job ${jobId}:`, error.message);
      return { success: false, error: error.message };
    }
  }

  /**
   * Stop a scheduled job
   */
  stopJob(jobId) {
    try {
      const job = this.jobs.get(jobId);
      if (job) {
        job.stop();
        this.jobs.delete(jobId);
        console.log(`⛔ Stopped job: ${jobId}`);
        return { success: true, message: `Job ${jobId} stopped` };
      }
      return { success: false, message: `Job ${jobId} not found` };
    } catch (error) {
      console.error(`❌ Error stopping job ${jobId}:`, error.message);
      return { success: false, error: error.message };
    }
  }

  /**
   * Get all scheduled jobs
   */
  getScheduledJobs() {
    return Array.from(this.jobs.keys());
  }

  /**
   * Stop all scheduled jobs
   */
  stopAllJobs() {
    try {
      for (const [jobId, job] of this.jobs) {
        job.stop();
      }
      this.jobs.clear();
      console.log("⛔ All scheduled jobs stopped");
      return { success: true, message: "All jobs stopped" };
    } catch (error) {
      console.error(`❌ Error stopping all jobs:`, error.message);
      return { success: false, error: error.message };
    }
  }

  /**
   * Validate cron expression
   */
  validateCronExpression(cronExpression) {
    try {
      cron.validate(cronExpression);
      return { valid: true };
    } catch (error) {
      return { valid: false, error: error.message };
    }
  }
}

export default new SchedulerService();

/**
 * Common Cron Expressions:
 *
 * 0 0 * * *           - Every day at midnight
 * 0 8 * * *           - Every day at 8 AM
 * 0 0 * * 1           - Every Monday at midnight
 * 0 0,12 * * *        - Twice a day (midnight and noon)
 * 0 0,6,12,18 * * *   - Every 6 hours
 * 0 (star)1 * * *     - Every hour
 * (star)15 * * * *    - Every 15 minutes
 * (star)5 * * * *     - Every 5 minutes
 * 0 0 1 * *           - First day of every month
 *
 * Cron Format: minute hour day month day-of-week
 * minute: 0-59
 * hour: 0-23
 * day: 1-31
 * month: 1-12
 * day-of-week: 0-6 (0=Sunday, 1=Monday, etc)
 */
