# SOLID Principles - Clean Code Foundations

## Single Responsibility Principle (SRP)

> A class should have only one reason to change.

Every module, class, or function should have responsibility over a single part of the functionality.

### Violation Example

```java
// BAD: Employee has THREE reasons to change
// 1. If pay calculation rules change (accounting)
// 2. If report format changes (HR)
// 3. If database schema changes (DBA)
public class Employee {
    public Money calculatePay() { ... }
    public String reportHours() { ... }
    public void save() { ... }
}
```

### Clean Solution

```java
// GOOD: Each class has ONE reason to change
public class Employee {
    private String name;
    private Money hourlyRate;
    // Just employee data
}

public class PayCalculator {
    public Money calculatePay(Employee e) { ... }
}

public class HourReporter {
    public String reportHours(Employee e) { ... }
}

public class EmployeeRepository {
    public void save(Employee e) { ... }
}
```

### How to Identify SRP Violations

Ask: "What does this class do?" If the answer contains "and," it probably violates SRP.

- "This class handles **user authentication and logging**" - Two responsibilities
- "This class **validates and saves** orders" - Two responsibilities
- "This class **formats and emails** reports" - Two responsibilities

## Open/Closed Principle (OCP)

> Software entities should be open for extension but closed for modification.

You should be able to add new functionality without changing existing code.

### Violation Example

```java
// BAD: Must modify this method to add new shapes
public class AreaCalculator {
    public double calculateArea(Object shape) {
        if (shape instanceof Rectangle) {
            Rectangle r = (Rectangle) shape;
            return r.width * r.height;
        } else if (shape instanceof Circle) {
            Circle c = (Circle) shape;
            return Math.PI * c.radius * c.radius;
        }
        // Must add new if-else for every new shape!
        return 0;
    }
}
```

### Clean Solution

```java
// GOOD: Add new shapes without modifying existing code
public interface Shape {
    double area();
}

public class Rectangle implements Shape {
    private double width, height;

    @Override
    public double area() {
        return width * height;
    }
}

public class Circle implements Shape {
    private double radius;

    @Override
    public double area() {
        return Math.PI * radius * radius;
    }
}

// Adding Triangle doesn't require changing anything!
public class Triangle implements Shape {
    private double base, height;

    @Override
    public double area() {
        return 0.5 * base * height;
    }
}

public class AreaCalculator {
    public double calculateArea(Shape shape) {
        return shape.area();  // Works for any shape, past or future
    }
}
```

## Liskov Substitution Principle (LSP)

> Subtypes must be substitutable for their base types.

If S is a subtype of T, then objects of type T can be replaced with objects of type S without altering the correctness of the program.

### Classic Violation: Rectangle/Square

```java
// BAD: Square is not a proper substitute for Rectangle
public class Rectangle {
    protected int width, height;

    public void setWidth(int w) { width = w; }
    public void setHeight(int h) { height = h; }
    public int area() { return width * height; }
}

public class Square extends Rectangle {
    // Violates LSP: changing width also changes height
    @Override
    public void setWidth(int w) {
        width = w;
        height = w;  // Surprise! This isn't what Rectangle does
    }

    @Override
    public void setHeight(int h) {
        width = h;
        height = h;
    }
}

// This test passes for Rectangle but fails for Square!
void testArea(Rectangle r) {
    r.setWidth(5);
    r.setHeight(4);
    assert r.area() == 20;  // Square returns 16!
}
```

### Clean Solution

```java
// GOOD: Separate abstractions
public interface Shape {
    int area();
}

public class Rectangle implements Shape {
    private final int width, height;

    public Rectangle(int w, int h) {
        width = w;
        height = h;
    }

    public int area() { return width * height; }
}

public class Square implements Shape {
    private final int side;

    public Square(int s) { side = s; }

    public int area() { return side * side; }
}
```

### LSP Warning Signs

- Throwing exceptions for methods inherited from base class
- Empty implementations of base class methods
- Using instanceof checks to determine type

## Interface Segregation Principle (ISP)

> Clients should not be forced to depend on interfaces they do not use.

Many specific interfaces are better than one general-purpose interface.

### Violation Example

```java
// BAD: Fat interface forces unnecessary dependencies
public interface Worker {
    void work();
    void eat();
    void sleep();
}

// Robot can't eat or sleep!
public class Robot implements Worker {
    public void work() { /* ... */ }
    public void eat() { throw new UnsupportedOperationException(); }
    public void sleep() { throw new UnsupportedOperationException(); }
}
```

### Clean Solution

```java
// GOOD: Segregated interfaces
public interface Workable {
    void work();
}

public interface Eatable {
    void eat();
}

public interface Sleepable {
    void sleep();
}

public class Human implements Workable, Eatable, Sleepable {
    public void work() { /* ... */ }
    public void eat() { /* ... */ }
    public void sleep() { /* ... */ }
}

public class Robot implements Workable {
    public void work() { /* ... */ }
    // No need to implement eat() or sleep()
}
```

## Dependency Inversion Principle (DIP)

> High-level modules should not depend on low-level modules. Both should depend on abstractions.
> Abstractions should not depend on details. Details should depend on abstractions.

### Violation Example

```java
// BAD: High-level PayrollService depends on low-level MySqlDatabase
public class PayrollService {
    private MySqlDatabase database = new MySqlDatabase();

    public void processPayroll() {
        List<Employee> employees = database.getEmployees();
        // ... process
        database.savePayments(payments);
    }
}
// Can't test without a MySQL database!
// Can't switch to PostgreSQL without modifying PayrollService!
```

### Clean Solution

```java
// GOOD: Both depend on abstraction
public interface EmployeeRepository {
    List<Employee> getEmployees();
    void savePayments(List<Payment> payments);
}

public class PayrollService {
    private final EmployeeRepository repository;

    // Dependency injected
    public PayrollService(EmployeeRepository repository) {
        this.repository = repository;
    }

    public void processPayroll() {
        List<Employee> employees = repository.getEmployees();
        // ... process
        repository.savePayments(payments);
    }
}

// Now we can have multiple implementations
public class MySqlEmployeeRepository implements EmployeeRepository { ... }
public class PostgresEmployeeRepository implements EmployeeRepository { ... }
public class InMemoryEmployeeRepository implements EmployeeRepository { ... }  // For testing!
```

### Dependency Injection

The key to DIP is dependency injection:

```java
// Constructor injection (preferred)
public class OrderService {
    private final PaymentGateway gateway;

    public OrderService(PaymentGateway gateway) {
        this.gateway = gateway;
    }
}

// Setter injection (use when optional)
public class ReportGenerator {
    private Logger logger = new NullLogger();

    public void setLogger(Logger logger) {
        this.logger = logger;
    }
}
```

## Summary

| Principle | One-Line Summary |
|-----------|------------------|
| **SRP** | One reason to change |
| **OCP** | Add, don't modify |
| **LSP** | Substitutable subtypes |
| **ISP** | Small, focused interfaces |
| **DIP** | Depend on abstractions |

When you violate these principles, you create code that is:
- Rigid (hard to change)
- Fragile (changes break unexpected things)
- Immobile (hard to reuse)
- Viscous (hard to do the right thing)

When you follow them, you create code that is:
- Flexible
- Robust
- Reusable
- Maintainable
