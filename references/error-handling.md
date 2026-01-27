# Error Handling - Clean Code Principles

## Use Exceptions Rather Than Return Codes

Return codes clutter the caller's code with error handling:

```java
// BAD: Return codes create nested conditionals
public class DeviceController {
    public void sendShutDown() {
        DeviceHandle handle = getHandle(DEV1);
        if (handle != DeviceHandle.INVALID) {
            DeviceRecord record = retrieveDeviceRecord(handle);
            if (record.getStatus() != DEVICE_SUSPENDED) {
                pauseDevice(handle);
                clearDeviceWorkQueue(handle);
                closeDevice(handle);
            } else {
                logger.log("Device suspended. Unable to shut down");
            }
        } else {
            logger.log("Invalid handle for: " + DEV1.toString());
        }
    }
}

// GOOD: Exceptions separate happy path from error handling
public class DeviceController {
    public void sendShutDown() {
        try {
            tryToShutDown();
        } catch (DeviceShutDownError e) {
            logger.log(e);
        }
    }

    private void tryToShutDown() throws DeviceShutDownError {
        DeviceHandle handle = getHandle(DEV1);
        DeviceRecord record = retrieveDeviceRecord(handle);

        pauseDevice(handle);
        clearDeviceWorkQueue(handle);
        closeDevice(handle);
    }
}
```

## Write Your Try-Catch-Finally Statement First

When you write code that might throw exceptions, start with try-catch-finally:

```java
// Start with the exception structure
public List<RecordedGrip> retrieveSection(String sectionName) {
    try {
        // Code that might fail
        FileInputStream stream = new FileInputStream(sectionName);
        // ... parse stream
    } catch (FileNotFoundException e) {
        throw new StorageException("retrieval error", e);
    } finally {
        // Cleanup
    }
    return new ArrayList<RecordedGrip>();
}
```

This helps you define what the caller can expect, no matter what goes wrong.

## Use Unchecked Exceptions

Checked exceptions violate the Open/Closed Principle:

```java
// BAD: Checked exception forces changes throughout call chain
public void method1() throws MyCheckedException {
    method2();
}

public void method2() throws MyCheckedException {
    method3();
}

public void method3() throws MyCheckedException {
    // actual throw here
}
// If we add a new exception to method3, we must change method1 and method2!
```

**The cost of checked exceptions:**
- Breaking encapsulation
- Changes cascade through the call stack
- Tight coupling between high and low level code

Use unchecked (runtime) exceptions instead.

## Provide Context with Exceptions

Create informative error messages:

```java
// BAD: No context
throw new RuntimeException();

// GOOD: Full context
throw new DeviceResponseException(
    "Device " + deviceId + " failed to respond to command " + command +
    " after " + timeout + "ms. Status: " + status);
```

Include:
- What operation was attempted
- What failed
- The state of the system

## Define Exception Classes by Caller's Needs

Wrap third-party APIs to simplify error handling:

```java
// BAD: Caller must handle many exception types
try {
    port.open();
} catch (DeviceResponseException e) {
    reportPortError(e);
    logger.log("Device response exception", e);
} catch (ATM1212UnlockedException e) {
    reportPortError(e);
    logger.log("Unlock exception", e);
} catch (GMXError e) {
    reportPortError(e);
    logger.log("Device response exception", e);
}

// GOOD: Wrap the API to simplify
public class LocalPort {
    private ACMEPort innerPort;

    public void open() {
        try {
            innerPort.open();
        } catch (DeviceResponseException e) {
            throw new PortDeviceFailure(e);
        } catch (ATM1212UnlockedException e) {
            throw new PortDeviceFailure(e);
        } catch (GMXError e) {
            throw new PortDeviceFailure(e);
        }
    }
}

// Now caller only handles one type
try {
    port.open();
} catch (PortDeviceFailure e) {
    reportError(e);
    logger.log(e.getMessage(), e);
}
```

## Define the Normal Flow

Don't let exceptions drive control flow. Use the Special Case Pattern:

```java
// BAD: Exception used for control flow
try {
    MealExpenses expenses = expenseReportDAO.getMeals(employee.getID());
    total += expenses.getTotal();
} catch (MealExpensesNotFound e) {
    total += getMealPerDiem();
}

// GOOD: Special case object handles the missing data
MealExpenses expenses = expenseReportDAO.getMeals(employee.getID());
total += expenses.getTotal();

// The DAO returns a special case object when no meals exist
public class PerDiemMealExpenses implements MealExpenses {
    public int getTotal() {
        return getMealPerDiem();  // Returns default per diem
    }
}
```

## Don't Return Null

Returning null creates work for callers and invites NullPointerExceptions:

```java
// BAD: Caller must check for null
List<Employee> employees = getEmployees();
if (employees != null) {
    for (Employee e : employees) {
        totalPay += e.getPay();
    }
}

// GOOD: Return empty collection instead
public List<Employee> getEmployees() {
    if (/* there are no employees */) {
        return Collections.emptyList();
    }
    // ...
}

// Now caller code is clean
for (Employee e : getEmployees()) {
    totalPay += e.getPay();
}
```

Consider using Optional (Java 8+) or the Null Object pattern:

```java
// Using Optional
public Optional<Employee> findEmployee(String id) {
    Employee e = lookup(id);
    return Optional.ofNullable(e);
}

// Caller must handle explicitly
findEmployee(id).ifPresent(e -> processEmployee(e));

// Or with default
Employee e = findEmployee(id).orElse(DEFAULT_EMPLOYEE);
```

## Don't Pass Null

Passing null is worse than returning null:

```java
// BAD: Null arguments
public double calculateArea(Point p1, Point p2) {
    // What if p1 or p2 is null?
    return (p2.x - p1.x) * (p2.y - p1.y);
}

// Defensive but cluttered
public double calculateArea(Point p1, Point p2) {
    if (p1 == null || p2 == null) {
        throw new IllegalArgumentException("Points cannot be null");
    }
    return (p2.x - p1.x) * (p2.y - p1.y);
}
```

**The best approach:** Forbid passing null by default. In most programming languages, there's no good way to deal with null passed by a careless caller.

## Fail Fast

When something is wrong, fail immediately with a clear error:

```java
// BAD: Silently continues with bad data
public void processOrder(Order order) {
    if (order == null) {
        return;  // Silent failure - debugging nightmare
    }
    // ...
}

// GOOD: Fail fast with clear message
public void processOrder(Order order) {
    Objects.requireNonNull(order, "Order cannot be null");
    // ...
}
```

## Summary

| Principle | Guideline |
|-----------|-----------|
| Return codes | Use exceptions instead |
| Checked exceptions | Prefer unchecked (runtime) |
| Exception messages | Provide full context |
| Third-party exceptions | Wrap them |
| Null returns | Return empty collections or Optional |
| Null parameters | Forbid them |
| Error handling | Separate from business logic |
| Failures | Fail fast with clear errors |
