# Assessment Tools Mobile App

This project is a mobile application designed to help teachers and students manage and interact with assessments. The app provides separate functionalities for teachers/admins and students, including assessment creation, management, taking assessments, and viewing analytics.

## Features

### 1. Assessment Dashboard (Teacher/Admin View)

- **Purpose**: A central hub for teachers to view, create, and manage assessments.
- **Components**:
  - My Assessments: View and manage existing assessments.
  - Create New Assessment: Start creating a new assessment.
  - Search and Filter: Search assessments by title or keywords and filter by type.

### 2. Assessment Creation Page (Teacher/Admin View)

- **Purpose**: Allows teachers to create various types of assessments like quizzes, assignments, and surveys.
- **Components**:
  - Assessment Title: Input field for the assessment title.
  - Assessment Type: Dropdown to select the type (e.g., quiz, assignment).
  - Question Bank Access: Select questions from an existing bank or create new ones.
  - Question Creation Tool: Create different types of questions (multiple-choice, short answer, essay, true/false).
  - Time Limit and Attempts: Set time limits and number of attempts.
  - Feedback Options: Define the feedback type (immediate or delayed).

### 3. Question Bank Management Page

- **Purpose**: Manage reusable questions that can be used across multiple assessments.
- **Components**:
  - Question List: View all questions with options to filter, add, edit, or delete.
  - Import/Export: Import questions from external sources or export them for use elsewhere.

### 4. Student View - Assessment Taking Page

- **Purpose**: Main interface for students to take assessments.
- **Components**:
  - Assessment Title and Instructions: Display the assessment details.
  - Timer Display: Show the remaining time if a time limit is set.
  - Question Navigation: Navigate between questions.
  - Save Progress: Save the current progress.
  - Submit Assessment: Submit the assessment for grading.

### 5. Assessment Review and Feedback Page

- **Purpose**: Allows students to review completed assessments and receive feedback.
- **Components**:
  - Detailed Feedback: Show feedback for each question.
  - Submission History: View previous attempts and feedback.

## Setup

### Prerequisites

- Flutter SDK installed
- Firebase account with Authentication and Firestore Database setup

### Firebase Setup

1. **Firebase Authentication**:
   - Enable authentication methods (e.g., Email/Password) in Firebase Console.
2. **Firestore Database**:
   - Set up Firestore Database with collections for assessments, question banks, and student data.
   - Define security rules to ensure proper access control.

### Installation

1. Clone the repository:
   git clone https://github.com/shankar64bit/managementsystem.git
   cd managementsystem

2. Install dependencies:
   flutter pub get

3. Configure Firebase:

   - Add `google-services.json` (Android) as per Firebase setup instructions.

4. Run the app:
   flutter run

## Usage

### For Teachers/Admins

- Log in with your credentials.
- Access the Assessment Dashboard to view, create, and manage assessments.
- Use the Question Bank to add or edit questions.

### For Students

- Log in with your student account.
- View and take available assessments.
- Review assessment on completed assessments through the history pages.

## Deployment

### Firebase Hosting

1. Install Firebase CLI:

   npm install -g firebase-tools

2. Login to Firebase:

   firebase login

3. Initialize Firebase in your project:

   firebase init

4. Deploy the app:

   firebase deploy

## Security

- Separate login flows for teachers/admins and students ensure data privacy.
- Firestore security rules are implemented to restrict access to sensitive data.
