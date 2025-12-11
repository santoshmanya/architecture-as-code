**Background**

Mastery is a web platform where:

Students browse tutorials, enroll, and track progress

Instructors create and manage tutorials

The platform sends progress emails and integrates with a payment provider for paid courses

1. C4 Level 1 – System Context

People

Student – Consumes tutorials, tracks progress

Instructor – Creates and manages tutorials

Admin – Manages users, content, and reports

Software Systems

Mastery Tutorial Platform (our system)

Email Service – Sends notification emails

Payment Provider – Handles payments

Context relationships

Student → uses → Mastery Tutorial Platform

Instructor → uses → Mastery Tutorial Platform

Admin → uses → Mastery Tutorial Platform

Mastery → sends email via → Email Service

Mastery → charges cards via → Payment Provider

<img width="1112" height="1088" alt="image" src="https://github.com/user-attachments/assets/f3792c46-df05-48aa-aefd-65de6da43b52" />









2. C4 Level 2 – Container Diagram (Mastery)

Containers in Mastery:

Web App (SPA) – Browser UI for students/instructors/admins

API Application – REST/GraphQL backend, core business logic

Background Worker – Async jobs (emails, reports)

Relational Database – Users, tutorials, enrollments, progress

Object Storage – Videos, PDFs, large assets

Auth Provider (External) – Authentication / tokens

Email Service (External)

Payment Provider (External)

Relationships:

People → Web App (HTTPS)

Web App → API Application (HTTPS/REST/GraphQL)

API Application ↔ Relational Database

API Application → Object Storage

API Application → Auth Provider

API Application → Payment Provider

API Application → Background Worker (direct or via queue)

Background Worker → Email Service

<img width="1190" height="1067" alt="image" src="https://github.com/user-attachments/assets/eccd45e6-7acb-4682-ae52-93e58462e6f7" />
<img width="1165" height="1110" alt="image" src="https://github.com/user-attachments/assets/555de3c1-549d-4155-98c9-7249cb55dfc7" />


Dynamic diagram

A dynamic diagram can be useful when you want to show how elements in the static model collaborate at runtime to implement a user story, use case, feature, etc. This is similar to sequence diagram in UML

Above diagram show, how email is triggered when student completes a lesson

3. C4 Level 3 – Components (inside Mastery API Application)

API Layer

AuthController

TutorialController

EnrollmentController

ProgressController

PaymentController

Services

UserService

TutorialService

EnrollmentService

ProgressService

RecommendationService

PaymentService

Repositories

UserRepository

TutorialRepository

EnrollmentRepository

ProgressRepository

Integration Clients

EmailClient (to Email Service)

PaymentClient (to Payment Provider)

StorageClient (to Object Storage)

Cross-cutting

AuditLogger

MetricsCollector

AuthTokenValidator

<img width="1225" height="723" alt="image" src="https://github.com/user-attachments/assets/ad3b612c-6932-4f07-9c4b-3c7f6846c816" />

4. C4 Level 4 – Code (e.g., ProgressService in Mastery)

Same code idea, just conceptually now part of Mastery’s API Application:

<img width="2473" height="1335" alt="image" src="https://github.com/user-attachments/assets/dc6395fa-2077-46d1-8c0c-d428c31044a7" />



References:

DSL Code for above example

Mastery_C4_Model.dsl
https://github.com/santoshmanya/architecture-as-code/blob/main/C4Model/Mastery_C4_Model.dsl

Screenshot of how to upload dsl file  in structurizr and render it.
