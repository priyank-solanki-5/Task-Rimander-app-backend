class RecurrenceHelper {
  /**
   * Calculate next occurrence date based on recurrence type
   * @param {Date} currentDate - Current due date
   * @param {string} recurrenceType - Monthly, Every 3 months, Every 6 months, Yearly
   * @returns {Date} - Next occurrence date
   */
  static calculateNextOccurrence(currentDate, recurrenceType) {
    if (!currentDate || !recurrenceType) {
      return null;
    }

    const nextDate = new Date(currentDate);

    switch (recurrenceType) {
      case "Monthly":
        nextDate.setMonth(nextDate.getMonth() + 1);
        break;
      case "Every 3 months":
        nextDate.setMonth(nextDate.getMonth() + 3);
        break;
      case "Every 6 months":
        nextDate.setMonth(nextDate.getMonth() + 6);
        break;
      case "Yearly":
        nextDate.setFullYear(nextDate.getFullYear() + 1);
        break;
      default:
        return null;
    }

    return nextDate;
  }

  /**
   * Validate recurrence type
   * @param {string} recurrenceType
   * @returns {boolean}
   */
  static isValidRecurrenceType(recurrenceType) {
    const validTypes = [
      "Monthly",
      "Every 3 months",
      "Every 6 months",
      "Yearly",
    ];
    return validTypes.includes(recurrenceType);
  }
}

export default RecurrenceHelper;
