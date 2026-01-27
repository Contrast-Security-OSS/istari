# Functions - Clean Code Principles

## The First Rule

Functions should be small. The second rule is they should be smaller than that.

**Target sizes:**
- Ideal: 4-5 lines
- Acceptable: under 20 lines
- Unacceptable: anything requiring scrolling

## Do One Thing

Functions should do ONE thing. Do it well. Do it ONLY.

How do you know if a function does one thing? If you can extract another function from it with a name that isn't a restatement of its implementation, it does more than one thing.

**The Stepdown Rule:** Code should read like a top-down narrative. Every function should be followed by those at the next level of abstraction.

```java
// Read like a newspaper - headline first, then details
public void generateReport() {
    loadData();
    processData();
    formatOutput();
    saveReport();
}

private void loadData() { ... }
private void processData() { ... }
private void formatOutput() { ... }
private void saveReport() { ... }
```

## Extract Till You Drop

Keep extracting functions until each one does exactly one thing:

```java
// Before: Multiple responsibilities
public void renderPage() {
    String pageText = getPageText();
    if (pageText.contains("test")) {
        WikiPage testPage = findTestPage();
        StringBuffer setup = new StringBuffer();
        setup.append(testPage.getSetup());
        pageText = setup + pageText;
    }
    // ... more mixing of abstraction levels
}

// After: One level of abstraction per function
public void renderPage() {
    includeSetupPagesIfTestPage();
    includePageContent();
    includeTeardownPagesIfTestPage();
}

private void includeSetupPagesIfTestPage() {
    if (isTestPage())
        includeSetupPages();
}

private boolean isTestPage() { ... }
private void includeSetupPages() { ... }
```

## Arguments

The ideal number of arguments is zero. Next comes one, followed closely by two. Three arguments should be avoided. More than three requires special justification.

### Monadic Forms (One Argument)

Good reasons for one argument:
- Asking a question: `boolean fileExists("myFile")`
- Transforming: `InputStream fileOpen("myFile")`
- Event: `void passwordAttemptFailedNtimes(int attempts)`

### Dyadic Functions (Two Arguments)

Two arguments are harder to understand:
```java
// Harder - which is first?
writeField(name, stream);

// Better - output stream as member
outputStream.writeField(name);
```

### Triadic Functions (Three Arguments)

Very hard to understand. Consider wrapping arguments in a class:
```java
// Hard to remember order
Circle makeCircle(double x, double y, double radius);

// Better
Circle makeCircle(Point center, double radius);
```

## No Flag Arguments

Flag arguments are ugly. They proclaim that the function does more than one thing.

```java
// TERRIBLE: What does true mean?
render(true);

// What this actually does
void render(boolean isSuite) {
    if (isSuite)
        renderForSuite();
    else
        renderForSingleTest();
}

// CLEAN: Just make two functions
renderForSuite();
renderForSingleTest();
```

## No Side Effects

Side effects are lies. Your function promises to do one thing but also does hidden things.

```java
// Side effect hidden in name
public boolean checkPassword(String userName, String password) {
    User user = findUser(userName);
    if (user != null && user.passwordMatches(password)) {
        Session.initialize();  // SIDE EFFECT!
        return true;
    }
    return false;
}

// Honest name if you must have the side effect
public boolean checkPasswordAndInitializeSession(...) { ... }

// Better: Separate the concerns
public boolean checkPassword(...) { ... }
public void initializeSession(...) { ... }
```

## Command Query Separation

Functions should either do something or answer something, but not both.

```java
// CONFUSING: Does it set or check?
if (set("username", "unclebob")) { ... }

// CLEAN: Separate command and query
if (attributeExists("username")) {
    setAttribute("username", "unclebob");
}
```

## Prefer Exceptions to Returning Error Codes

Error codes force nested conditionals:

```java
// MESSY: Error code handling
if (deletePage(page) == E_OK) {
    if (registry.deleteReference(page.name) == E_OK) {
        if (configKeys.deleteKey(page.name.makeKey()) == E_OK) {
            logger.log("page deleted");
        } else {
            logger.log("configKey not deleted");
        }
    } else {
        logger.log("deleteReference failed");
    }
} else {
    logger.log("delete failed");
}

// CLEAN: Exceptions
try {
    deletePage(page);
    registry.deleteReference(page.name);
    configKeys.deleteKey(page.name.makeKey());
} catch (Exception e) {
    logger.log(e.getMessage());
}
```

## Extract Try/Catch Blocks

Try/catch blocks are ugly. Extract the bodies into functions:

```java
// CLEAN: Try block calls one function
public void delete(Page page) {
    try {
        deletePageAndAllReferences(page);
    } catch (Exception e) {
        logError(e);
    }
}

private void deletePageAndAllReferences(Page page) throws Exception {
    deletePage(page);
    registry.deleteReference(page.name);
    configKeys.deleteKey(page.name.makeKey());
}

private void logError(Exception e) {
    logger.log(e.getMessage());
}
```

## Don't Repeat Yourself (DRY)

Duplication is the root of all evil in software. Every piece of knowledge should have a single, unambiguous representation.

When you see duplication, extract it into a function.
