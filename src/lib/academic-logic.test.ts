import test from 'node:test';
import assert from 'node:assert/strict';
import {
  scoreToGPA,
  calculateCumulativeGPA,
  calculateAttendanceMetrics,
  hasPermission,
  filterAndSortSchedules,
  type GradeItem,
  type AttendanceRecord,
  type ScheduleItem,
} from './academic-logic';

test('scoreToGPA converts scores to letter grade and GPA correctly', () => {
  assert.deepEqual(scoreToGPA(95, 100), { gpa: 4.0, letter: 'A' });
  assert.deepEqual(scoreToGPA(82, 100), { gpa: 3.3, letter: 'B+' });
  assert.deepEqual(scoreToGPA(74, 100), { gpa: 2.7, letter: 'B-' });
  assert.deepEqual(scoreToGPA(62, 100), { gpa: 2.0, letter: 'C' });
  assert.deepEqual(scoreToGPA(45, 100), { gpa: 0.0, letter: 'E' });
});

test('calculateCumulativeGPA handles multiple assignments', () => {
  const grades: GradeItem[] = [
    { score: 90, maxScore: 100 },
    { score: 80, maxScore: 100 },
    { score: 70, maxScore: 100 },
  ];
  const result = calculateCumulativeGPA(grades);
  assert.equal(result.averageScore, 80);
  assert.equal(typeof result.gpa, 'number');
  assert.ok(result.gpa >= 3.0 && result.gpa <= 3.5);
});

test('calculateAttendanceMetrics computes accurate counts and rates', () => {
  const records: AttendanceRecord[] = [
    { status: 'PRESENT' },
    { status: 'PRESENT' },
    { status: 'LATE' },
    { status: 'EXCUSED' },
    { status: 'ABSENT' },
  ];
  const metrics = calculateAttendanceMetrics(records);
  assert.equal(metrics.total, 5);
  assert.equal(metrics.presentCount, 2);
  assert.equal(metrics.lateCount, 1);
  assert.equal(metrics.excusedCount, 1);
  assert.equal(metrics.absentCount, 1);
  assert.ok(metrics.rate > 0 && metrics.rate < 100);
});

test('RBAC permissions validate correctly for all roles', () => {
  assert.equal(hasPermission('ADMIN', 'school:manage'), true);
  assert.equal(hasPermission('STUDENT', 'school:manage'), false);
  assert.equal(hasPermission('TEACHER', 'attendance:mark_class'), true);
  assert.equal(hasPermission('PARENT', 'attendance:view_child'), true);
  assert.equal(hasPermission('STUDENT', 'grades:edit_all'), false);
});

test('filterAndSortSchedules filters by day and sorts chronologically', () => {
  const schedules: ScheduleItem[] = [
    { id: '1', subjectName: 'Fisika', dayOfWeek: 1, startTime: '09:00', endTime: '10:30' },
    { id: '2', subjectName: 'Matematika', dayOfWeek: 1, startTime: '07:30', endTime: '09:00' },
    { id: '3', subjectName: 'Biologi', dayOfWeek: 2, startTime: '07:30', endTime: '09:00' },
  ];

  const monday = filterAndSortSchedules(schedules, 1);
  assert.equal(monday.length, 2);
  assert.equal(monday[0].subjectName, 'Matematika');
  assert.equal(monday[1].subjectName, 'Fisika');
});
