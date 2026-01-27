# Comments - Clean Code Principles

## The Fundamental Truth

> "The proper use of comments is to compensate for our failure to express ourselves in code."

Comments are, at best, a necessary evil. Every time you write a comment, you should grimace and feel the failure of your ability to express yourself in code.

**Why comments are bad:**
- They lie. Code changes, comments don't always follow.
- They're often out of date.
- They clutter the code.
- They're an excuse not to write clear code.

## Don't Comment Bad Code - Rewrite It

```java
// BAD: Comment explaining confusing code
// Check to see if employee is eligible for full benefits
if ((employee.flags & HOURLY_FLAG) && (employee.age > 65))

// GOOD: Clear code needs no comment
if (employee.isEligibleForFullBenefits())
```

## Comments That Are Acceptable

### Legal Comments

Copyright and licensing statements:
```java
// Copyright (C) 2023 by Company Inc. All rights reserved.
// Released under the MIT License.
```

### Informative Comments

Explaining obscure patterns like regex:
```java
// format matched: kk:mm:ss EEE, MMM dd, yyyy
Pattern timeMatcher = Pattern.compile("\\d*:\\d*:\\d* \\w*, \\w* \\d*, \\d*");
```

### Explanation of Intent

When the reason isn't obvious from the code:
```java
// We prefer this over the faster algorithm because
// we need the results to be stable for the UI.
Collections.sort(list, comparator);
```

### Warning of Consequences

```java
// Don't run unless you have several hours to spare.
public void testWithRealExternalService() { ... }

// SimpleDateFormat is not thread-safe, so we create one per thread.
private static final ThreadLocal<SimpleDateFormat> df = ...
```

### TODO Comments

For work that should be done but can't be done now:
```java
// TODO: We expect this to go away when we implement the checkout feature
protected VersionInfo makeVersion() throws Exception {
    return null;
}
```

**Warning:** Don't leave TODOs forever. They rot.

### Amplification

Emphasizing importance that might seem inconsequential:
```java
// the trim is real important. It removes the starting spaces
// that could cause the item to be recognized as another list.
String listItemContent = match.group(3).trim();
```

## Comments That Are Unacceptable

### Mumbling

If you must write a comment, spend the time to make it good:
```java
// BAD: What does this mean?
// Utility method for instantiation
public void doSomething() { ... }
```

### Redundant Comments

Comments that say exactly what the code says:
```java
// BAD: Completely redundant
// returns the day of the month
public int getDayOfMonth() {
    return dayOfMonth;
}

// BAD: The javadoc is less informative than the code
/**
 * The processor delay for this component.
 */
protected int backgroundProcessorDelay = -1;
```

### Misleading Comments

Comments that are inaccurate:
```java
// BAD: This comment lies - method doesn't close if timeout occurs
// This method will close the connection when timeout is reached
public synchronized void sendShutdown() {
    // ... code that doesn't actually close on timeout
}
```

### Mandated Comments

Don't require javadocs for every function:
```java
// BAD: Adds nothing, just clutter
/**
 * @param title The title of the CD
 * @param author The author of the CD
 */
public void addCD(String title, String author) {
    // ...
}
```

### Journal Comments

Don't keep a log of changes in comments. That's what version control is for:
```java
// BAD: Change log
// 2023-01-10 - Fixed bug in calculation (Bob)
// 2023-01-05 - Added validation (Alice)
// 2023-01-01 - Initial implementation (Charlie)
```

### Noise Comments

Comments that restate the obvious:
```java
// BAD: Noise
/** Default constructor */
public AnnualDateRule() { }

/** The day of the month */
private int dayOfMonth;

// BAD: Scary noise
/** The name. */
private String name;

/** The version. */
private String version;

/** The info. */
private String info;
```

### Position Markers

Don't use banner comments:
```java
// BAD: Banner comment
// ==================== Actions ====================
```

### Closing Brace Comments

If your function is so long you need these, the function is too long:
```java
// BAD: Need to mark closing braces
while (condition) {
    // lots of code
    // more code
    // even more code
} // end while

// GOOD: Short function doesn't need markers
while (condition) {
    doOneThing();
}
```

### Attributions and Bylines

Version control tracks who wrote what:
```java
// BAD: Author attribution in code
/* Added by Bob */
```

### Commented-Out Code

**Delete it!** Version control remembers it:
```java
// BAD: Commented-out code
// InputStreamReader reader = new InputStreamReader(is);
// BufferedReader br = new BufferedReader(reader);
// String line;
// while ((line = br.readLine()) != null) {
//     lineCount++;
// }
```

Other programmers are afraid to delete commented code. They think it's there for a reason. It accumulates like sediment.

### HTML Comments

Don't put HTML in comments. Let the documentation tool handle formatting:
```java
// BAD: HTML in comments
/**
 * <p>This is a <b>really</b> important method.</p>
 * <ul>
 *   <li>First thing</li>
 *   <li>Second thing</li>
 * </ul>
 */
```

### Nonlocal Information

Don't put system-wide information in local comments:
```java
// BAD: Information about something elsewhere in the system
/**
 * Port on which server runs. Default is 8080.
 */
public void setPort(int port) {
    this.port = port;
}
// What if the default changes elsewhere?
```

### Too Much Information

Don't put historical discussions or irrelevant descriptions:
```java
// BAD: Too much information
/*
RFC 2045 - Multipurpose Internet Mail Extensions (MIME)
Part One: Format of Internet Message Bodies
Section 6.8.  Base64 Content-Transfer-Encoding

The encoding process represents 24-bit groups of input bits as output
strings of 4 encoded characters. Proceeding from left to right, a
24-bit input group is formed by concatenating 3 8-bit input groups...
[goes on for pages]
*/
```

### Inobvious Connection

The comment should explain what isn't obvious in the code:
```java
// BAD: Comment doesn't explain why 200 is used
/*
 * start with an array that is big enough to hold all the pixels
 * (plus filter bytes), and an extra 200 bytes for header info
 */
this.pngBytes = new byte[((this.width + 1) * this.height * 3) + 200];
// Why 200? The comment doesn't help.
```
