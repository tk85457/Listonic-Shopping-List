# Supabase Authentication Setup Guide

Yeh guide aapko Supabase dashboard mein Phone aur Google authentication enable karne mein help karega.

## 📋 Prerequisites

1. Supabase account (https://supabase.com)
2. Supabase project already created
3. Project URL aur anon key available

---

## 🔐 Phone Authentication Setup (SMS/OTP)

### Step 1: Supabase Dashboard mein Provider Enable karein

1. **Supabase Dashboard** mein jayein: https://app.supabase.com
2. Apna **project** select karein
3. Left sidebar se **Authentication** → **Providers** par click karein
4. **Phone** provider ko find karein
5. **Enable Phone** toggle ko **ON** karein

### Step 2: SMS Provider Configure karein

Supabase SMS ke liye **Twilio** use karta hai. Aapko 2 options hain:

#### Option A: Twilio Account Setup (Recommended for Production)

1. **Twilio Account** banayein: https://www.twilio.com/try-twilio
2. Twilio dashboard se:
   - **Account SID** copy karein
   - **Auth Token** copy karein
   - **Phone Number** (verified) copy karein
3. Supabase Dashboard → **Project Settings** → **Auth** → **SMS Auth**
4. Twilio credentials add karein:
   - **Twilio Account SID**
   - **Twilio Auth Token**
   - **Twilio Phone Number**
5. **Save** karein

#### Option B: Supabase Test Mode (Development ke liye)

1. Supabase Dashboard → **Authentication** → **Providers** → **Phone**
2. **Enable Phone** toggle ON karein
3. **Test Mode** enable karein (development ke liye)
4. Test mode mein OTP automatically verify ho jata hai (123456)

### Step 3: Phone Number Format

- App mein phone number **+91** prefix ke saath automatically add hota hai
- Format: `+91XXXXXXXXXX` (10 digits)
- Example: `+919876543210`

### Step 4: Verify Configuration

1. App mein phone number enter karein
2. OTP receive karein
3. OTP verify karein

---

## 🔵 Google Sign-In Setup

### Step 1: Google Cloud Console Setup

1. **Google Cloud Console** mein jayein: https://console.cloud.google.com
2. **New Project** banayein ya existing project select karein
3. **APIs & Services** → **Library** mein jayein
4. **Google+ API** enable karein (agar available ho)
5. **Credentials** page par jayein

### Step 2: SHA-1 Fingerprint Nikalna (Android ke liye zaroori)

**Important:** Android app ke liye Google Sign-In enable karne ke liye SHA-1 fingerprint chahiye.

#### Quick Method (Gradle se):
```bash
cd android
.\gradlew signingReport
```

Output mein **SHA1:** wala fingerprint copy karein.

#### Alternative Method (Keytool se):
```bash
cd %USERPROFILE%\.android
keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Detailed guide:** `HOW_TO_GET_SHA1_FINGERPRINT.md` file dekhein.

### Step 3: OAuth 2.0 Client ID Create karein

1. **Create Credentials** → **OAuth client ID** select karein
2. Agar pehle se OAuth consent screen setup nahi hai:
   - **Configure Consent Screen** par click karein
   - **External** select karein (agar public app hai)
   - **App name**, **User support email** fill karein
   - **Save and Continue**
   - Scopes skip karein (default theek hai)
   - **Save and Continue**
   - Test users add karein (agar external mode hai)
   - **Back to Dashboard**

3. **Web Application Client ID** banayein:
   - **Application type**: **Web application** select karein
   - **Name**: "Smart Grocery List Web Client"
   - **Authorized redirect URIs** mein add karein:
     ```
     https://syfoiyzasquehymefhhf.supabase.co/auth/v1/callback
     ```
   - **Create** karein
   - **Client ID** aur **Client Secret** copy karein (important!)

4. **Android Application Client ID** banayein:
   - **Create Credentials** → **OAuth client ID** phir se select karein
   - **Application type**: **Android** select karein
   - **Name**: "Smart Grocery List Android"
   - **Package name**: `com.smartgrocery.smartgrocerylist`
   - **SHA-1 certificate fingerprint**: Step 2 se copy kiya hua SHA-1 fingerprint paste karein
   - **Create** karein

### Step 3: Supabase mein Google Provider Enable karein

1. **Supabase Dashboard** → **Authentication** → **Providers**
2. **Google** provider ko find karein
3. **Enable Google** toggle ko **ON** karein
4. **Client ID (for OAuth)** field mein Google Client ID paste karein
5. **Client Secret (for OAuth)** field mein Google Client Secret paste karein
6. **Save** karein

### Step 4: Redirect URL Configure karein

1. Supabase Dashboard → **Authentication** → **URL Configuration**
2. **Redirect URLs** section mein add karein:
   ```
   com.smartgrocery.smartgrocerylist://login-callback
   ```
3. **Save** karein

### Step 5: Android App Configuration

Android app mein deep link already configure hai (`AndroidManifest.xml` mein):
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="com.smartgrocery.smartgrocerylist" android:host="login-callback" />
</intent-filter>
```

### Step 6: Verify Google Sign-In

1. App mein **"Continue with Google"** button par click karein
2. Browser open hoga Google sign-in ke liye
3. Google account select karein
4. App automatically return ho jayega aur sign-in complete hoga

---

## ⚠️ Common Issues aur Solutions

### Issue 1: "SMS provider is not enabled"

**Solution:**
- Supabase Dashboard → Authentication → Providers → Phone → Enable karein
- Twilio credentials add karein ya Test Mode enable karein

### Issue 2: "Google provider not enabled"

**Solution:**
- Supabase Dashboard → Authentication → Providers → Google → Enable karein
- Google OAuth Client ID aur Secret add karein
- Redirect URL verify karein

### Issue 3: "Invalid redirect URI"

**Solution:**
- Google Cloud Console mein authorized redirect URI add karein:
  ```
  https://syfoiyzasquehymefhhf.supabase.co/auth/v1/callback
  ```
- Supabase Dashboard mein app redirect URL add karein:
  ```
  com.smartgrocery.smartgrocerylist://login-callback
  ```

### Issue 4: OTP receive nahi ho raha

**Solution:**
- Twilio account verify karein
- Phone number format check karein (+91 prefix)
- Twilio phone number verified hai ya nahi check karein
- Test Mode use karein development ke liye

### Issue 5: Google Sign-In browser open nahi ho raha

**Solution:**
- Internet connection check karein
- Google OAuth credentials verify karein
- Redirect URL Supabase aur Google Cloud Console dono mein same hai ya nahi check karein

---

## 📝 Important Notes

1. **Development vs Production:**
   - Development ke liye SMS Test Mode use karein
   - Production ke liye Twilio account setup karein

2. **Cost:**
   - Twilio SMS charges apply hote hain (per SMS)
   - Google OAuth free hai

3. **Security:**
   - Client Secret ko kabhi bhi publicly expose mat karein
   - Supabase anon key secure rakhein

4. **Testing:**
   - Pehle Test Mode mein test karein
   - Phir production credentials use karein

---

## 🔗 Useful Links

- Supabase Dashboard: https://app.supabase.com
- Google Cloud Console: https://console.cloud.google.com
- Twilio Console: https://www.twilio.com/console
- Supabase Auth Docs: https://supabase.com/docs/guides/auth

---

## ✅ Verification Checklist

### Phone Authentication:
- [ ] Supabase Dashboard mein Phone provider enabled hai
- [ ] Twilio credentials add kiye gaye hain (ya Test Mode ON hai)
- [ ] Phone number format correct hai (+91XXXXXXXXXX)
- [ ] OTP receive ho raha hai

### Google Sign-In:
- [ ] Google Cloud Console mein OAuth client ID create kiya gaya hai
- [ ] Supabase Dashboard mein Google provider enabled hai
- [ ] Google Client ID aur Secret add kiye gaye hain
- [ ] Redirect URLs dono platforms par configure hain
- [ ] AndroidManifest.xml mein deep link configure hai
- [ ] Google Sign-In button kaam kar raha hai

---

**Setup complete hone ke baad app restart karein aur test karein!**
