# Testing - Clean Code Principles

## The Three Laws of TDD

1. **You may not write production code until you have written a failing unit test.**

2. **You may not write more of a unit test than is sufficient to fail, and not compiling is failing.**

3. **You may not write more production code than is sufficient to pass the currently failing test.**

This creates a cycle of about 30 seconds:
- Write a tiny test that fails
- Write just enough code to make it pass
- Refactor
- Repeat

## Keeping Tests Clean

**Test code is just as important as production code.** It requires thought, design, and care. It must be kept as clean as production code.

```java
// BAD: Messy test - hard to understand
public void testGetPageHieratchyAsXml() throws Exception {
    crawler.addPage(root, PathParser.parse("PageOne"));
    crawler.addPage(root, PathParser.parse("PageOne.ChildOne"));
    crawler.addPage(root, PathParser.parse("PageTwo"));

    request.setResource("root");
    request.addInput("type", "pages");
    Responder responder = new SerializedPageResponder();
    SimpleResponse response =
        (SimpleResponse) responder.makeResponse(
            new FitNesseContext(root), request);
    String xml = response.getContent();

    assertEquals("text/xml", response.getContentType());
    assertSubString("<name>PageOne</name>", xml);
    assertSubString("<name>PageTwo</name>", xml);
    assertSubString("<name>ChildOne</name>", xml);
}

// GOOD: Clean test - reads like a specification
public void testGetPageHierarchyAsXml() throws Exception {
    givenPages("PageOne", "PageOne.ChildOne", "PageTwo");

    whenRequestIsIssued("root", "type:pages");

    thenResponseShouldBeXML();
    thenResponseShouldContain(
        "<name>PageOne</name>",
        "<name>PageTwo</name>",
        "<name>ChildOne</name>"
    );
}
```

## F.I.R.S.T. Principles

### Fast

Tests should run quickly. When tests run slow, you won't run them frequently. When you don't run them frequently, you won't find problems early.

### Independent

Tests should not depend on each other. One test should not set up conditions for the next. You should be able to run each test independently and in any order.

```java
// BAD: Tests depend on each other
@Test public void testCreateUser() {
    user = createUser("Bob");  // Sets shared state
    assertNotNull(user);
}

@Test public void testDeleteUser() {
    deleteUser(user);  // Depends on testCreateUser running first!
    assertNull(findUser("Bob"));
}

// GOOD: Tests are independent
@Test public void testCreateUser() {
    User user = createUser("Bob");
    assertNotNull(user);
}

@Test public void testDeleteUser() {
    User user = createUser("Bob");  // Sets up its own data
    deleteUser(user);
    assertNull(findUser("Bob"));
}
```

### Repeatable

Tests should be repeatable in any environment: development, QA, production, on the train without a network.

Don't depend on:
- Network availability
- Database state
- File system state
- Current time (mock it!)
- Random numbers (seed them!)

### Self-Validating

Tests should have a boolean output: pass or fail. You should not have to read through logs or compare files manually.

```java
// BAD: Requires manual verification
@Test public void testOutput() {
    System.out.println(calculate(5, 3));
    // Did it print 8? Developer has to check manually.
}

// GOOD: Self-validating
@Test public void testCalculation() {
    assertEquals(8, calculate(5, 3));
}
```

### Timely

Tests should be written just before the production code that makes them pass. If you write tests after the production code, you may find the production code hard to test.

## One Assert Per Test

Each test function should test one concept:

```java
// BAD: Multiple concepts in one test
@Test
public void testAddAndRemoveAndModify() {
    // Test add
    list.add("item");
    assertEquals(1, list.size());

    // Test remove
    list.remove("item");
    assertEquals(0, list.size());

    // Test modify... where does this test stop?
}

// GOOD: One concept per test
@Test
public void addingItemIncreasesSize() {
    list.add("item");
    assertEquals(1, list.size());
}

@Test
public void removingItemDecreasesSize() {
    list.add("item");
    list.remove("item");
    assertEquals(0, list.size());
}
```

**Note:** "One assert" is a guideline, not a rule. Sometimes you need multiple asserts to test one concept:

```java
// OK: Multiple asserts testing one concept (user was created correctly)
@Test
public void createdUserHasCorrectProperties() {
    User user = createUser("Bob", "bob@test.com");

    assertEquals("Bob", user.getName());
    assertEquals("bob@test.com", user.getEmail());
    assertNotNull(user.getId());
    assertTrue(user.isActive());
}
```

## Test Naming

Test names should describe what is being tested and what the expected outcome is:

```java
// BAD: Vague names
@Test void test1() { }
@Test void testProcess() { }
@Test void testValidation() { }

// GOOD: Descriptive names
@Test void withdrawalReducesBalance() { }
@Test void overdraftThrowsInsufficientFundsException() { }
@Test void depositToClosedAccountThrowsException() { }
@Test void newAccountHasZeroBalance() { }
```

## The Build-Operate-Check Pattern

Structure tests in three parts:

```java
@Test
public void transferMovesMoneyBetweenAccounts() {
    // BUILD: Set up the test data
    Account source = new Account(100);
    Account destination = new Account(0);

    // OPERATE: Execute the operation being tested
    source.transfer(50, destination);

    // CHECK: Verify the results
    assertEquals(50, source.getBalance());
    assertEquals(50, destination.getBalance());
}
```

Also known as:
- **Arrange-Act-Assert** (AAA)
- **Given-When-Then**

## Testing Boundaries

Test at the boundaries - that's where bugs hide:

```java
@Test void emptyListReturnsNull() { }
@Test void singleElementList() { }
@Test void listWithManyElements() { }
@Test void nullInputThrowsException() { }
@Test void negativeIndexThrowsException() { }
@Test void indexEqualToSizeThrowsException() { }
@Test void maxIntegerValue() { }
@Test void minIntegerValue() { }
```

## Don't Test Private Methods

If you feel the need to test private methods, it's a sign the class is doing too much. Extract the private methods into a new class where they become public.

```java
// BAD: Feeling the need to test private method
public class Order {
    public double getTotal() {
        return calculateSubtotal() + calculateTax();
    }

    private double calculateTax() {
        // Complex logic you want to test
    }
}

// GOOD: Extract into testable class
public class Order {
    private TaxCalculator taxCalculator;

    public double getTotal() {
        return calculateSubtotal() + taxCalculator.calculate(this);
    }
}

public class TaxCalculator {
    public double calculate(Order order) {
        // Now this is public and testable
    }
}
```

## Test Code Quality

Apply the same quality standards to test code:
- Meaningful names
- Small functions
- No duplication (extract common setup)
- Clear intent

```java
// Use helper methods to improve readability
private Account accountWithBalance(int balance) {
    Account account = new Account();
    account.deposit(balance);
    return account;
}

private void assertBalanceEquals(int expected, Account account) {
    assertEquals(expected, account.getBalance());
}

@Test
public void transferDeductsFromSource() {
    Account source = accountWithBalance(100);
    Account destination = accountWithBalance(0);

    source.transfer(30, destination);

    assertBalanceEquals(70, source);
}
```

## Summary

| Principle | Description |
|-----------|-------------|
| TDD | Test first, then code |
| Clean tests | As important as production code |
| F.I.R.S.T. | Fast, Independent, Repeatable, Self-validating, Timely |
| One concept | One test per concept |
| Naming | Describe behavior and expectation |
| Build-Operate-Check | Structure tests clearly |
| Boundaries | Test edge cases |
| No private testing | Extract to testable class instead |
