/**
 * Pure business logic for Quick Schools Academic calculations & RBAC rules.
 * Shared between Web and Mobile integrations.
 */

export type Role = 'ADMIN' | 'TEACHER' | 'STUDENT' | 'PARENT';

export type AttendanceStatus = 'PRESENT' | 'LATE' | 'EXCUSED' | 'ABSENT';

export interface GradeItem {
  score: number;
  maxScore: number;
}

export interface AttendanceRecord {
  status: AttendanceStatus;
}

export interface ScheduleItem {
  id: string;
  subjectName: string;
  dayOfWeek: number;
  startTime: string;
  endTime: string;
}

/**
 * Calculates letter grade and 4.0 scale GPA from percentage
 */
export function scoreToGPA(score: number, maxScore: number = 100): { gpa: number; letter: string } {
  if (maxScore <= 0) return { gpa: 0, letter: 'E' };
  const percentage = (score / maxScore) * 100;

  if (percentage >= 90) return { gpa: 4.0, letter: 'A' };
  if (percentage >= 85) return { gpa: 3.7, letter: 'A-' };
  if (percentage >= 80) return { gpa: 3.3, letter: 'B+' };
  if (percentage >= 75) return { gpa: 3.0, letter: 'B' };
  if (percentage >= 70) return { gpa: 2.7, letter: 'B-' };
  if (percentage >= 65) return { gpa: 2.3, letter: 'C+' };
  if (percentage >= 60) return { gpa: 2.0, letter: 'C' };
  if (percentage >= 50) return { gpa: 1.0, letter: 'D' };
  return { gpa: 0.0, letter: 'E' };
}

/**
 * Calculates average score and cumulative GPA from multiple grade items
 */
export function calculateCumulativeGPA(grades: GradeItem[]): { averageScore: number; gpa: number } {
  if (!grades || grades.length === 0) {
    return { averageScore: 0, gpa: 0 };
  }

  let totalScorePercentage = 0;
  let totalGPA = 0;

  for (const grade of grades) {
    const { gpa, letter: _ } = scoreToGPA(grade.score, grade.maxScore);
    totalScorePercentage += (grade.score / grade.maxScore) * 100;
    totalGPA += gpa;
  }

  const averageScore = Number((totalScorePercentage / grades.length).toFixed(1));
  const gpa = Number((totalGPA / grades.length).toFixed(2));

  return { averageScore, gpa };
}

/**
 * Calculates attendance rate percentage
 * Present = 100% weight, Late = 75% weight, Excused = 100% non-penalized, Absent = 0%
 */
export function calculateAttendanceMetrics(records: AttendanceRecord[]) {
  if (!records || records.length === 0) {
    return {
      rate: 100,
      presentCount: 0,
      lateCount: 0,
      excusedCount: 0,
      absentCount: 0,
      total: 0,
    };
  }

  let presentCount = 0;
  let lateCount = 0;
  let excusedCount = 0;
  let absentCount = 0;

  for (const rec of records) {
    switch (rec.status) {
      case 'PRESENT':
        presentCount++;
        break;
      case 'LATE':
        lateCount++;
        break;
      case 'EXCUSED':
        excusedCount++;
        break;
      case 'ABSENT':
        absentCount++;
        break;
    }
  }

  const attended = presentCount + (lateCount * 0.8) + (excusedCount * 1.0);
  const rate = Number(((attended / records.length) * 100).toFixed(1));

  return {
    rate: Math.min(100, Math.max(0, rate)),
    presentCount,
    lateCount,
    excusedCount,
    absentCount,
    total: records.length,
  };
}

/**
 * Strict RBAC permission matrix for Quick Schools
 */
export const RBAC_PERMISSIONS: Record<Role, string[]> = {
  ADMIN: [
    'school:view',
    'school:manage',
    'users:manage',
    'classes:manage',
    'attendance:view_all',
    'attendance:mark_all',
    'grades:view_all',
    'grades:edit_all',
    'announcements:broadcast',
    'audit_logs:view',
  ],
  TEACHER: [
    'classes:view_assigned',
    'attendance:view_class',
    'attendance:mark_class',
    'grades:view_class',
    'grades:edit_assigned',
    'announcements:view',
    'announcements:broadcast',
  ],
  STUDENT: [
    'attendance:view_self',
    'attendance:mark_self',
    'schedule:view_enrolled',
    'grades:view_self',
    'announcements:view',
    'profile:view_self',
  ],
  PARENT: [
    'attendance:view_child',
    'schedule:view_child',
    'grades:view_child',
    'announcements:view',
    'profile:view_child',
  ],
};

export function hasPermission(role: Role, requiredPermission: string): boolean {
  const permissions = RBAC_PERMISSIONS[role];
  if (!permissions) return false;
  return permissions.includes(requiredPermission);
}

/**
 * Filters schedules by day and sorts by start time
 */
export function filterAndSortSchedules(schedules: ScheduleItem[], targetDay: number): ScheduleItem[] {
  return schedules
    .filter((s) => s.dayOfWeek === targetDay)
    .sort((a, b) => a.startTime.localeCompare(b.startTime));
}
