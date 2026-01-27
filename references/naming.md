# Naming - Clean Code Principles

## Use Intention-Revealing Names

The name of a variable, function, or class should answer all the big questions: why it exists, what it does, and how it is used.

```java
// BAD: What does d mean?
int d; // elapsed time in days

// GOOD: Name reveals intent
int elapsedTimeInDays;
int daysSinceCreation;
int daysSinceModification;
int fileAgeInDays;
```

## Avoid Disinformation

Avoid words whose entrenched meanings vary from our intended meaning.

```java
// BAD: It's not actually a List (it's a Map)
Map<String, Account> accountList;

// GOOD: Accurate name
Map<String, Account> accounts;
Map<String, Account> accountsByName;
```

Don't use names that vary in small ways:
```java
// BAD: Too similar
XYZControllerForEfficientHandlingOfStrings
XYZControllerForEfficientStorageOfStrings

// GOOD: Meaningfully different
StringHandlingController
StringStorageController
```

## Make Meaningful Distinctions

Don't add noise words just to satisfy the compiler:

```java
// BAD: Noise words
class ProductInfo { }
class ProductData { }
// What's the difference between Info and Data?

// BAD: Number series
void copyChars(char a1[], char a2[]) {
    for (int i = 0; i < a1.length; i++) {
        a2[i] = a1[i];
    }
}

// GOOD: Meaningful names
void copyChars(char[] source, char[] destination) {
    for (int i = 0; i < source.length; i++) {
        destination[i] = source[i];
    }
}
```

Noise words are redundant:
- `nameString` - Would a name be a floating point number?
- `customerObject` - What else would it be?
- `theMessage` - How is it different from `message`?

## Use Pronounceable Names

If you can't pronounce it, you can't discuss it without sounding like an idiot.

```java
// BAD: Unpronounceable
class DtaRcrd102 {
    private Date genymdhms;  // generation year month day hour minute second
    private Date modymdhms;
}

// GOOD: Pronounceable
class Customer {
    private Date generationTimestamp;
    private Date modificationTimestamp;
}
```

## Use Searchable Names

Single-letter names and numeric constants are hard to locate across a body of text.

```java
// BAD: What is 5? Can't search for it.
for (int j = 0; j < 34; j++) {
    s += (t[j] * 4) / 5;
}

// GOOD: Named constants are searchable
int realDaysPerIdealDay = 4;
const int WORK_DAYS_PER_WEEK = 5;
int sum = 0;
for (int j = 0; j < NUMBER_OF_TASKS; j++) {
    int realTaskDays = taskEstimate[j] * realDaysPerIdealDay;
    int realTaskWeeks = realTaskDays / WORK_DAYS_PER_WEEK;
    sum += realTaskWeeks;
}
```

**Rule:** The length of a name should correspond to the size of its scope. Single-letter names are only acceptable for short methods with tiny scopes.

## Avoid Encodings

### Hungarian Notation - Don't Use It

With modern IDEs, type information is redundant:

```java
// BAD: Hungarian notation
PhoneNumber strPhoneNumber;
int iCount;
String m_description;

// GOOD: Just the name
PhoneNumber phoneNumber;
int count;
String description;
```

### Member Prefixes - Don't Use Them

```java
// BAD: m_ prefix
public class Part {
    private String m_description;
}

// GOOD: No prefix needed
public class Part {
    private String description;
}
```

### Interface and Implementation

Don't mark interfaces with `I`:

```java
// BAD
interface IShapeFactory { }
class ShapeFactory implements IShapeFactory { }

// GOOD: If you must distinguish, mark the implementation
interface ShapeFactory { }
class ShapeFactoryImpl implements ShapeFactory { }
// Or better:
class ConcreteShapeFactory implements ShapeFactory { }
```

## Class Names

Classes and objects should have noun or noun phrase names:
- `Customer`, `WikiPage`, `Account`, `AddressParser`

Avoid words like `Manager`, `Processor`, `Data`, `Info` - they are often meaningless.

```java
// BAD: What does Manager even mean?
class CustomerManager { }
class DataProcessor { }

// GOOD: Specific nouns
class CustomerRegistry { }
class TransactionParser { }
```

## Method Names

Methods should have verb or verb phrase names:
- `postPayment`, `deletePage`, `save`

Accessors, mutators, and predicates should follow JavaBean standard:
- `getName`, `setName`, `isPosted`

```java
// Use static factory methods with descriptive names
// BAD
Complex c = new Complex(23.0);

// GOOD
Complex c = Complex.fromRealNumber(23.0);
```

## Don't Be Cute

Say what you mean. Mean what you say.

```java
// BAD: Cute/clever names
void holyHandGrenade() { }  // What does this do?
void whack() { }            // Kill? Delete? Hit?
void eatMyShorts() { }      // Abort? Exit?

// GOOD: Clear names
void deleteItems() { }
void abort() { }
void quit() { }
```

## Pick One Word Per Concept

Pick one word for one abstract concept and stick with it:
- Don't use `fetch`, `retrieve`, and `get` for equivalent methods
- Don't use `controller`, `manager`, and `driver` for equivalent classes

```java
// BAD: Inconsistent vocabulary
class DeviceManager { }
class ProtocolController { }
class DriverHandler { }

// GOOD: Consistent vocabulary
class DeviceController { }
class ProtocolController { }
class DriverController { }
```

## Use Solution Domain Names

Use computer science terms, algorithm names, pattern names:

```java
// GOOD: Programmers will understand these
class AccountVisitor { }  // Visitor pattern
class JobQueue { }        // Queue data structure
void quickSort() { }      // Known algorithm
```

## Use Problem Domain Names

When there is no solution domain name, use names from the problem domain:

```java
// GOOD: Domain expert can verify correctness
class MortgageAmortizationSchedule { }
class InsurancePremiumCalculator { }
```

## Add Meaningful Context

Most names are not meaningful in themselves. Place names in context with enclosing classes, functions, or namespaces.

```java
// BAD: What does state mean here?
String firstName;
String lastName;
String street;
String houseNumber;
String city;
String state;  // State of what?
String zipcode;

// GOOD: Context through class
class Address {
    String firstName;
    String lastName;
    String street;
    String houseNumber;
    String city;
    String state;  // Now clearly part of address
    String zipcode;
}
```

## Don't Add Gratuitous Context

Shorter names are generally better, if they are clear.

```java
// BAD: Redundant context
class GasStationDeluxeAddress { }  // In GasStationDeluxe app
class GasStationDeluxeMailingAddress { }
class GasStationDeluxeAccountAddress { }

// GOOD: Simple and clear
class Address { }
class MailingAddress { }
class AccountAddress { }
```
