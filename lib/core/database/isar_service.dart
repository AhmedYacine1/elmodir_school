import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// Import all model schemas
import '../../models/student.dart';
import '../../models/parent.dart';
import '../../models/staff.dart';
import '../../models/class.dart';
import '../../models/attendance.dart';
import '../../models/payment.dart';
import '../../models/expense.dart';
import '../../models/user.dart';

class IsarService {
  static late Isar isar;

  // Initialize Isar database
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([
      StudentSchema,
      ParentSchema,
      StaffSchema,
      ClassSchema,
      AttendanceSchema,
      PaymentSchema,
      ExpenseSchema,
      UserSchema,
    ], directory: dir.path);
  }

  // Close the database
  static Future<void> close() async {
    await isar.close();
  }

  // Get all students
  static Future<List<Student>> getAllStudents() async {
    return await isar.students.where().findAll();
  }

  // Add or update student
  static Future<int> putStudent(Student student) async {
    return await isar.writeTxn(() async {
      return await isar.students.put(student);
    });
  }

  // Delete student
  static Future<void> deleteStudent(int id) async {
    await isar.writeTxn(() async {
      await isar.students.delete(id);
    });
  }

  // Get all parents
  static Future<List<Parent>> getAllParents() async {
    return await isar.parents.where().findAll();
  }

  // Add or update parent
  static Future<int> putParent(Parent parent) async {
    return await isar.writeTxn(() async {
      return await isar.parents.put(parent);
    });
  }

  // Get all staff
  static Future<List<Staff>> getAllStaff() async {
    return await isar.staffs.where().findAll();
  }

  // Add or update staff
  static Future<int> putStaff(Staff staff) async {
    return await isar.writeTxn(() async {
      return await isar.staffs.put(staff);
    });
  }

  // Get all classes
  static Future<List<ClassModel>> getAllClasses() async {
    return await isar.classes.where().findAll();
  }

  // Add or update class
  static Future<int> putClass(ClassModel classModel) async {
    return await isar.writeTxn(() async {
      return await isar.classes.put(classModel);
    });
  }

  // Get all attendance records
  static Future<List<Attendance>> getAllAttendance() async {
    return await isar.attendances.where().findAll();
  }

  // Add or update attendance
  static Future<int> putAttendance(Attendance attendance) async {
    return await isar.writeTxn(() async {
      return await isar.attendances.put(attendance);
    });
  }

  // Get all payments
  static Future<List<Payment>> getAllPayments() async {
    return await isar.payments.where().findAll();
  }

  // Add or update payment
  static Future<int> putPayment(Payment payment) async {
    return await isar.writeTxn(() async {
      return await isar.payments.put(payment);
    });
  }

  // Get all expenses
  static Future<List<Expense>> getAllExpenses() async {
    return await isar.expenses.where().findAll();
  }

  // Add or update expense
  static Future<int> putExpense(Expense expense) async {
    return await isar.writeTxn(() async {
      return await isar.expenses.put(expense);
    });
  }

  // Get all users
  static Future<List<User>> getAllUsers() async {
    return await isar.users.where().findAll();
  }

  // Add or update user
  static Future<int> putUser(User user) async {
    return await isar.writeTxn(() async {
      return await isar.users.put(user);
    });
  }

  // Find user by username
  static Future<User?> findUserByUsername(String username) async {
    return await isar.users.filter().usernameEquals(username).findFirst();
  }

  // Get total students count
  static Future<int> getTotalStudentsCount() async {
    return await isar.students.where().count();
  }

  // Get total active students count
  static Future<int> getTotalActiveStudentsCount() async {
    return await isar.students.filter().isActiveTrue().count();
  }

  // Get monthly income for a specific month and year
  static Future<double> getMonthlyIncome(DateTime date) async {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0);
    
    final payments = await isar.payments
        .filter()
        .paymentDateBetween(startOfMonth, endOfMonth)
        .statusEquals('paid')
        .findAll();
        
    return payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  // Get unpaid students count
  static Future<int> getUnpaidStudentsCount() async {
    final allStudents = await isar.students.where().findAll();
    final allPayments = await isar.payments.where().findAll();
    
    final paidStudentIds = allPayments
        .where((payment) => payment.status == 'paid' || 
                           payment.status == 'partial')
        .map((payment) => payment.studentId)
        .toSet();
    
    return allStudents
        .where((student) => !paidStudentIds.contains(student.id))
        .length;
  }

  // Get attendance summary for a specific date
  static Future<Map<String, int>> getAttendanceSummary(DateTime date) async {
    final attendances = await isar.attendances
        .filter()
        .dateBetween(
          DateTime(date.year, date.month, date.day),
          DateTime(date.year, date.month, date.day + 1),
        )
        .findAll();
    
    final summary = {'present': 0, 'absent': 0, 'justified': 0};
    
    for (final attendance in attendances) {
      if (summary.containsKey(attendance.status)) {
        summary[attendance.status] = summary[attendance.status]! + 1;
      }
    }
    
    return summary;
  }
}