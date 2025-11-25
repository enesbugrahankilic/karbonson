# Firebase Security Rules Deployment Guide

## Overview

This guide provides step-by-step instructions for deploying the Firebase Security Rules that enforce UID Centrality in your KarbonSon application.

## Prerequisites

1. Firebase CLI installed and configured
2. Firebase project created and linked
3. Appropriate Firebase permissions (Project Owner or Editor)

## Deployment Steps

### 1. Install Firebase CLI

```bash
npm install -g firebase-tools
```

### 2. Login to Firebase

```bash
firebase login
```

### 3. Initialize Firebase in your project (if not already done)

```bash
firebase init
```

Select the following when prompted:
- Firestore
- Hosting (if using web hosting)
- Functions (if using Cloud Functions)

### 4. Deploy Security Rules

```bash
# Deploy only the Firestore security rules
firebase deploy --only firestore:rules

# Or deploy everything (rules, functions, hosting, etc.)
firebase deploy
```

### 5. Verify Deployment

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Navigate to your project
3. Go to Firestore Database → Rules tab
4. Verify that the rules match the content in `firebase/firestore.rules`

## Security Rules Content

The deployed rules enforce:

```javascript
// Key security principles:
1. Users can only access their own data (document ID must match Auth UID)
2. Friend requests are restricted to involved parties only
3. Users can only modify their own friends subcollections
4. Notifications are private to each user
5. Game rooms allow read access for joining, write access for participants
```

## Testing Security Rules

### 1. Test with Firebase Emulator

```bash
# Start the emulator suite
firebase emulators:start --only firestore

# Run your app against the emulator to test rules
```

### 2. Test with Real Firebase

1. Deploy the rules
2. Test various operations in your app:
   - Try to access another user's data (should fail)
   - Try to modify someone else's profile (should fail)
   - Test friend request operations
   - Verify game room access controls

## Rollback Procedure

If you need to rollback the rules:

### Quick Rollback (via Console)
1. Go to Firebase Console
2. Navigate to Firestore Database → Rules
3. Click "Publish"
4. Revert to previous rules

### Programmatic Rollback
```bash
# If you have previous rules version saved
firebase deploy --only firestore:rules
```

## Monitoring

### Check Rule Performance
1. Firebase Console → Firestore Database → Usage tab
2. Monitor read/write operations
3. Check for rule-related errors in logs

### Security Monitoring
1. Firebase Console → Authentication → Users tab
2. Monitor authentication events
3. Check for unusual access patterns

## Troubleshooting

### Common Issues

1. **Rules not deploying**
   - Check Firebase CLI version: `firebase --version`
   - Ensure proper project selection: `firebase use <project-id>`

2. **Tests failing after deployment**
   - Verify rules syntax: `firebase firestore:rules:check firebase/firestore.rules`
   - Check authentication flow in your app

3. **Users locked out**
   - Immediately rollback rules via console
   - Investigate the specific rule causing the issue

### Debug Commands

```bash
# Check current project
firebase projects:list
firebase use

# Validate rules syntax
firebase firestore:rules:check firebase/firestore.rules

# Deploy with verbose output
firebase deploy --only firestore:rules --debug
```

## Security Best Practices

1. **Rule Testing**: Always test rules in emulator before production deployment
2. **Incremental Updates**: Deploy rule changes gradually
3. **Monitoring**: Set up alerts for unusual database activity
4. **Backup**: Keep previous versions of rules for quick rollback
5. **Documentation**: Document rule changes with version control

## Additional Resources

- [Firebase Security Rules Documentation](https://firebase.google.com/docs/rules)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [Firestore Security Rules Simulator](https://firebase.google.com/docs/rules/rules-editor)

## Verification Checklist

After deployment, verify that:

- [ ] Rules are active in Firebase Console
- [ ] Users can create profiles with their UID
- [ ] Users can only access their own data
- [ ] Friend requests work between users
- [ ] Game operations function correctly
- [ ] No unauthorized data access is possible

## Support

If you encounter issues during deployment:

1. Check the Firebase Console for detailed error messages
2. Review the Firebase CLI output for specific issues
3. Consult the Firebase documentation for rule-specific problems
4. Test in the emulator environment first

---

**Note**: This deployment guide assumes a standard Firebase setup. Your specific project configuration may require additional steps or modifications.