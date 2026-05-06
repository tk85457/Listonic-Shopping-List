# Fix Authentication Configuration in Supabase

Based on the images you uploaded, there are two configuration issues in your Supabase Dashboard that need to be fixed.

## 1. Fix Phone Sign-In Error (Image 1)
**Error:** `Invalid From Number (caller ID)`
**Cause:** The phone number configured in Supabase (sourced from Twilio) to *send* the SMS is invalid or incorrect.

**Steps to Fix:**
1. Log in to your **Supabase Dashboard**.
2. Go to **Authentication** -> **Providers**.
3. Click on **Phone**.
4. Look at the **Twilio** (or other provider) settings.
5. Check the **"Twilio Phone Number"** or **"Message Service SID"** field.
   - ensuring it matches exactly what is in your Twilio Console.
   - If using a phone number, it must be in E.164 format (e.g., `+1234567890`) and must be a number you *own* in Twilio.

   > [!TIP]
   > **Using a US Number (+1)?**
   > Yes, you can use a US number! However, if you are sending SMS to Indian numbers (+91):
   > 1. Go to **Twilio Console** > **Messaging** > **Settings** > **Geo Permissions**.
   > 2. Search for "India" (or your target country) and **Enable** it.
   > 3. Verify you have sufficient credits (international SMS costs more).
6. Click **Save**.

## 2. Fix Google Sign-In Error (Image 2)
**Error:** `Unsupported provider: missing OAuth secret`
**Cause:** The Google Provider in Supabase is enabled, but the **Client Secret** (and possibly Client ID) is missing.

**Steps to Fix:**
1. Log in to your **Supabase Dashboard**.
2. Go to **Authentication** -> **Providers**.
3. Click on **Google**.
4. You will see fields for **Client ID** and **Client Secret**.
   - These appear to be empty or incorrect based on the error.
5. Go to your **Google Cloud Console** -> **APIs & Services** -> **Credentials**.
6. Copy the **Client ID** and **Client Secret** for your Web Application.
7. Paste them into the Supabase Google Provider settings.
8. Click **Save**.

## 3. Fix "Error 400: redirect_uri_mismatch"
**Error:** `Access blocked: This app's request is invalid... redirect_uri_mismatch`
**Cause:** Google doesn't recognize your Supabase Project as an allowed callback.

**Steps to Fix:**
1. Go to **Google Cloud Console** > **APIs & Services** > **Credentials**.
2. Click on the **OAuth 2.0 Client ID** you created (Web client).
3. Scroll down to **"Authorized redirect URIs"**.
4. Click **Add URI** and paste exactly this URL:

   `https://syfoiyzasquehymefhhf.supabase.co/auth/v1/callback`

5. Click **Save**.
6. Wait 1-2 minutes for changes to propagate.

> [!NOTE]
> Also ensure that in **Supabase Dashboard** > **Authentication** > **URL Configuration**, you have added your app's deep link:
> `com.tk854.grocerylist://login-callback`

