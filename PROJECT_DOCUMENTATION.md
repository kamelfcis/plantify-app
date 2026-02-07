# Plantify - Plant Care & Disease Detection Application
## Project Documentation

---

# Table of Contents

**Chapter 1: Introduction** ………………………………………………………………...…….1  
1.0 Introduction……………………………………………………………………………….1  
1.1 Problem Domain……………………………………………………………………….…1  
1.2 Problem Statement………………………………………………………………………1  
1.3 Proposed System…………………………………………………………………………1  
1.3.1 Aims and Objectives………………………………………………………………….1  
1.3.2 Proposed System Features……………………………………………………………1  
1.4 Project Methodology…………………………………………………………………….1  
1.5 Resource Requirements………………………………………………………………….1  
1.6 Report Layout……………………………………………………………………………1  

**Chapter 2: Background/Existing Work** ………………………………………………….……2  
2.0 Introduction………………………………………………………………………………2  
2.1 Overview of Existing Projects……………………………………………………….…2  
2.2 Limitations of Existing Projects…………………………………………………….…2  
2.3 Innovations of Our Project………………………………………………………….…2  

**Chapter 3: Software Requirements Specifications** ………………………………….………3  
3.0 Introduction………………………………………………………………………………3  
3.1 Functional Requirements……………………………………………………………….3  
3.2 Non-Functional Requirements……………………………………………………….…4  
3.3 System Requirements……………………………………………………………………4  
3.4 Use Cases…………………………………………………………………………………5  

**Chapter 4: Software Design** …………………………………………………………….………9  
4.0 Introduction………………………………………………………………………………9  
4.1 System Architecture…………………………………………………………………….9  
4.2 Database Design…………………………………………………………………………11  
4.3 Class Design………………………………………………………………………………13  
4.4 Use Case Model………………………………………………………………………….14  
4.5 Sequence Diagrams………………………………………………………………………15  
4.6 Activity Diagrams………………………………………………………………………16  
4.7 Component Diagram…………………………………………………………………….22  
4.8 Deployment Diagram……………………………………………………………………23  

---

# Chapter 1: Introduction

## 1.0 Introduction

Plantify is a comprehensive mobile application designed to assist plant enthusiasts and gardeners in managing their plant collections, detecting plant diseases, and providing intelligent care recommendations. The application leverages artificial intelligence and modern mobile technologies to create an intuitive platform for plant care management.

## 1.1 Problem Domain

The domain of plant care and management has traditionally relied on manual methods, reference books, and expert consultation. Modern challenges in this domain include:

- **Disease Identification**: Plant diseases can be difficult to identify without expert knowledge, leading to delayed treatment and plant loss.
- **Care Management**: Tracking watering schedules, growth progress, and health status for multiple plants becomes complex.
- **Knowledge Accessibility**: Plant care information is scattered across various sources, making it difficult to access when needed.
- **Shopping Experience**: Finding and purchasing plants and related products requires visiting multiple physical stores or websites.

## 1.2 Problem Statement

Current plant care applications lack comprehensive features that combine disease detection, care management, and e-commerce capabilities. Users face challenges in:

1. **Timely Disease Detection**: Identifying plant diseases early enough to apply effective treatments.
2. **Maintaining Care Schedules**: Remembering when to water, fertilize, or perform other care tasks for multiple plants.
3. **Tracking Plant Growth**: Monitoring plant health and growth over time without systematic recording.
4. **Accessing Plant Information**: Quickly identifying unknown plants and accessing relevant care instructions.
5. **Shopping for Plants**: Finding quality plants and accessories through a convenient platform.

## 1.3 Proposed System

### 1.3.1 Aims and Objectives

**Primary Aims:**
- Develop a mobile application that assists users in plant care management using AI-powered disease detection.
- Create an integrated platform combining plant care, disease identification, and e-commerce capabilities.
- Provide real-time notifications and reminders for plant care activities.
- Enable users to track plant health and growth over time.

**Objectives:**
1. Implement AI-based plant disease detection using image recognition.
2. Develop plant identification functionality using machine learning models.
3. Create a comprehensive plant care management system with reminders and tracking.
4. Build an integrated marketplace for plants and related products.
5. Design an intuitive user interface accessible to users of all technical levels.
6. Ensure data security and privacy for user information and plant collections.

### 1.3.2 Proposed System Features

**Core Features:**
1. **AI-Powered Disease Detection**: Users can upload plant images to detect diseases and receive treatment recommendations.
2. **Plant Identification**: AI identifies plant species from photographs and provides detailed information.
3. **Plant Collection Management**: Users can add, organize, and track multiple plants in their collection.
4. **Health Tracking**: Record and monitor plant health status and growth percentage over time.
5. **Care Reminders**: Automated notifications for watering, fertilizing, and other care activities.
6. **Plant Marketplace**: Browse and purchase plants, accessories, and related products.
7. **Order Management**: Track orders and send plants as gifts to others.
8. **User Profiles**: Manage personal information and preferences.

**Advanced Features:**
- Real-time synchronization across devices
- Offline mode for viewing plant information
- Social sharing of plant achievements
- Personalized care recommendations based on plant health history

## 1.4 Project Methodology

The project follows an **Agile Development Methodology** with the following phases:

1. **Requirements Gathering**: Analysis of user needs and system requirements.
2. **System Design**: Architecture design, database schema, and UI/UX design.
3. **Implementation**: Development using Flutter for mobile app and Supabase for backend.
4. **Testing**: Unit testing, integration testing, and user acceptance testing.
5. **Deployment**: Release to app stores and continuous monitoring.

**Technology Stack:**
- **Frontend**: Flutter (Dart) for cross-platform mobile development
- **Backend**: Supabase (PostgreSQL, REST API, Authentication, Storage)
- **AI/ML**: TensorFlow Lite for on-device inference, Cloud-based ML models
- **State Management**: BLoC or Provider pattern
- **Database**: PostgreSQL via Supabase
- **Version Control**: Git

## 1.5 Resource Requirements

**Hardware Requirements:**
- Development machines with minimum 8GB RAM
- Android devices (API level 21+) for testing
- iOS devices (iOS 12+) for testing
- Cloud infrastructure for backend and AI services

**Software Requirements:**
- Flutter SDK (latest stable version)
- Android Studio / Xcode for mobile development
- Supabase account for backend services
- ML model training infrastructure (GPU recommended)
- Git for version control

**Human Resources:**
- Mobile Application Developers
- Backend Developers
- AI/ML Engineers
- UI/UX Designers
- Quality Assurance Engineers

**External Services:**
- Supabase for database and authentication
- Cloud ML services for AI model deployment
- Image storage and CDN services

## 1.6 Report Layout

This documentation is organized as follows:

- **Chapter 1**: Introduction to the project, problem domain, and proposed solution
- **Chapter 2**: Review of existing systems and innovations of our project
- **Chapter 3**: Detailed software requirements specifications
- **Chapter 4**: Comprehensive software design including architecture, database design, and UML diagrams
- **Chapter 5**: Implementation details (to be added)
- **Chapter 6**: Testing and validation (to be added)
- **Chapter 7**: Results and evaluation (to be added)
- **Chapter 8**: Conclusion and future work (to be added)

---

# Chapter 2: Background/Existing Work

## 2.0 Introduction

This chapter provides an overview of existing plant care applications and systems, analyzes their limitations, and highlights the innovations that Plantify brings to the domain.

## 2.1 Overview of Existing Projects

**Plant Care Applications:**
1. **PlantNet**: Focuses on plant identification through image recognition. Users can identify plants but lack comprehensive care management features.
2. **Garden Answers**: Provides plant identification and basic Q&A functionality. Limited in disease detection capabilities.
3. **Watering Reminder Apps**: Simple apps focusing only on watering schedules without comprehensive health tracking.
4. **Plant Care Apps**: Basic tracking applications that require manual data entry without AI assistance.

**E-commerce Platforms:**
- General gardening e-commerce websites exist but are separate from plant care applications.
- No integrated solution combining care management with shopping experience.

**Key Observations:**
- Most applications focus on single features (identification OR tracking OR shopping).
- Limited AI integration for disease detection.
- Fragmented user experience across multiple platforms.

## 2.2 Limitations of Existing Projects

1. **Limited AI Integration**: Most apps lack advanced AI-powered disease detection and diagnosis capabilities.

2. **Feature Fragmentation**: Users must use multiple applications to manage different aspects of plant care:
   - One app for identification
   - Another for tracking
   - Separate websites for purchasing

3. **Poor User Experience**: 
   - Complex interfaces that are difficult for non-technical users
   - Limited offline functionality
   - No synchronization across devices

4. **Incomplete Data Tracking**: 
   - Limited history tracking
   - No growth percentage monitoring
   - Basic reminder systems without intelligence

5. **Lack of Integration**: 
   - No connection between plant care data and marketplace
   - Cannot link plant purchases to care tracking automatically

6. **Limited Personalization**: 
   - Generic care instructions without considering plant history
   - No AI-powered recommendations based on user's plant collection

## 2.3 Innovations of Our Project

**Plantify addresses the limitations above through:**

1. **Comprehensive AI Integration**:
   - **Disease Detection Model**: Advanced image recognition to identify plant diseases with high accuracy
   - **Plant Identification Model**: Instant identification of plant species from photos
   - **Care Recommendation Engine**: AI-powered personalized care suggestions based on plant health history
   - **Chatbot Assistant**: Natural language interface for plant care questions

2. **Unified Platform**:
   - Single application combining all plant care features
   - Integrated marketplace eliminating the need for separate shopping platforms
   - Seamless data flow between care tracking and product recommendations

3. **Intelligent Tracking System**:
   - Automated health status updates through AI analysis
   - Growth percentage tracking with visual history
   - Smart reminders that adapt based on plant condition and season

4. **Enhanced User Experience**:
   - Intuitive interface designed for all user levels
   - Offline mode for viewing plant information
   - Real-time synchronization across all user devices
   - Social features for sharing plant progress

5. **Data-Driven Insights**:
   - Historical health tracking with timeline visualization
   - Pattern recognition in plant care habits
   - Predictive alerts for potential issues

6. **Integrated E-commerce**:
   - Purchase plants directly from care recommendations
   - Gift sending functionality integrated with care tracking
   - Personalized product recommendations based on user's collection

7. **Scalable Architecture**:
   - Cloud-based backend ensuring reliability and scalability
   - Modern mobile framework (Flutter) for cross-platform development
   - RESTful API design for future integrations

---

# Chapter 3: Software Requirements Specifications

## 3.0 Introduction

This chapter defines the functional and non-functional requirements for the Plantify application, providing a comprehensive specification of what the system must accomplish.

## 3.1 Functional Requirements

### FR1: User Authentication and Profile Management
- **FR1.1**: Users shall be able to register using email and password
- **FR1.2**: Users shall be able to login and logout
- **FR1.3**: Users shall be able to view and update their profile information
- **FR1.4**: Users shall be able to upload profile pictures

### FR2: Plant Disease Detection
- **FR2.1**: Users shall be able to upload or capture plant images
- **FR2.2**: The system shall analyze images using AI to detect diseases
- **FR2.3**: The system shall display disease detection results with confidence scores
- **FR2.4**: The system shall provide treatment recommendations for detected diseases
- **FR2.5**: Users shall be able to save detection results to plant records

### FR3: Plant Identification
- **FR3.1**: Users shall be able to take or upload plant photos for identification
- **FR3.2**: The system shall identify plant species using AI
- **FR3.3**: The system shall display plant information (name, scientific name, category)
- **FR3.4**: The system shall show care instructions for identified plants
- **FR3.5**: Users shall be able to add identified plants to their collection

### FR4: Plant Collection Management
- **FR4.1**: Users shall be able to add plants to their collection
- **FR4.2**: Users shall be able to view all plants in their collection
- **FR4.3**: Users shall be able to update plant information
- **FR4.4**: Users shall be able to delete plants from collection
- **FR4.5**: Users shall be able to upload plant images

### FR5: Plant Health Tracking
- **FR5.1**: Users shall be able to record plant health status (Excellent, Good, Fair, Poor)
- **FR5.2**: Users shall be able to update growth percentage
- **FR5.3**: Users shall be able to view health history timeline
- **FR5.4**: Users shall be able to add notes and images to health records
- **FR5.5**: Users shall be able to update next watering date

### FR6: Care Reminders
- **FR6.1**: Users shall be able to create care reminders
- **FR6.2**: Users shall be able to link reminders to specific plants
- **FR6.3**: Users shall be able to set reminder types (watering, fertilizing, pruning)
- **FR6.4**: Users shall be able to set repeat frequency (Daily, Weekly, Once)
- **FR6.5**: The system shall send push notifications for reminders
- **FR6.6**: Users shall be able to view, update, and delete reminders

### FR7: Marketplace
- **FR7.1**: Users shall be able to browse product catalog
- **FR7.2**: Users shall be able to search and filter products
- **FR7.3**: Users shall be able to view product details
- **FR7.4**: Users shall be able to add products to shopping cart
- **FR7.5**: Users shall be able to view cart contents

### FR8: Order Management
- **FR8.1**: Users shall be able to place orders
- **FR8.2**: Users shall be able to enter shipping address
- **FR8.3**: Users shall be able to review order before confirmation
- **FR8.4**: Users shall be able to view order history
- **FR8.5**: Users shall be able to track order status
- **FR8.6**: Users shall be able to send orders as gifts
- **FR8.7**: Users shall be able to add gift messages

### FR9: History and Reports
- **FR9.1**: Users shall be able to view plant health history
- **FR9.2**: Users shall be able to view order history
- **FR9.3**: The system shall display health timelines with images and notes

## 3.2 Non-Functional Requirements

### NFR1: Performance
- **NFR1.1**: Application startup time shall be less than 3 seconds
- **NFR1.2**: Image upload and processing shall complete within 10 seconds
- **NFR1.3**: Database queries shall respond within 2 seconds
- **NFR1.4**: The app shall support at least 1000 plants per user

### NFR2: Usability
- **NFR2.1**: The interface shall be intuitive and require minimal training
- **NFR2.2**: All actions shall provide visual feedback
- **NFR2.3**: Error messages shall be clear and actionable
- **NFR2.4**: The app shall support both portrait and landscape orientations

### NFR3: Reliability
- **NFR3.1**: System uptime shall be at least 99.5%
- **NFR3.2**: Data loss shall be prevented through automatic backups
- **NFR3.3**: The app shall handle network failures gracefully
- **NFR3.4**: Critical operations shall be logged for debugging

### NFR4: Security
- **NFR4.1**: User passwords shall be encrypted using industry standards
- **NFR4.2**: All API communications shall use HTTPS
- **NFR4.3**: User data shall be protected with row-level security
- **NFR4.4**: Personal information shall comply with data protection regulations

### NFR5: Scalability
- **NFR5.1**: The system shall support at least 10,000 concurrent users
- **NFR5.2**: Database shall be designed for horizontal scaling
- **NFR5.3**: Storage shall scale automatically with usage

### NFR6: Compatibility
- **NFR6.1**: Android: Minimum API level 21 (Android 5.0)
- **NFR6.2**: iOS: Minimum iOS 12.0
- **NFR6.3**: The app shall work on devices with minimum 2GB RAM

### NFR7: Maintainability
- **NFR7.1**: Code shall follow Flutter best practices
- **NFR7.2**: Documentation shall be maintained for all modules
- **NFR7.3**: Code shall have at least 70% test coverage

## 3.3 System Requirements

### Software Requirements
- **Operating System**: Android 5.0+ or iOS 12.0+
- **Development Environment**: Flutter SDK 3.0+, Dart 3.0+
- **Backend**: Supabase account and services
- **Database**: PostgreSQL 13+
- **ML Framework**: TensorFlow Lite for mobile, Cloud ML for server

### Hardware Requirements (Development)
- **Processor**: Intel Core i5 or equivalent
- **RAM**: Minimum 8GB (16GB recommended)
- **Storage**: 10GB free space for development tools
- **GPU**: Optional but recommended for ML model training

### Hardware Requirements (User Devices)
- **Android**: Devices with ARM processors, 2GB+ RAM
- **iOS**: iPhone 6s or later, iPad Air 2 or later
- **Camera**: Required for plant image capture
- **Storage**: 100MB free space for app installation

## 3.4 Use Cases

### UC1: User Registration
- **Actor**: New User
- **Precondition**: User does not have an account
- **Main Flow**:
  1. User opens application
  2. User selects "Register"
  3. User enters email, password, and name
  4. System validates input
  5. System creates account
  6. User receives confirmation

### UC2: Plant Disease Detection
- **Actor**: User
- **Precondition**: User is logged in
- **Main Flow**:
  1. User navigates to Disease Detection
  2. User captures or uploads plant image
  3. System processes image using AI model
  4. System displays disease result
  5. System shows treatment recommendations
  6. User can save result to plant record

### UC3: Add Plant to Collection
- **Actor**: User
- **Precondition**: User is logged in
- **Main Flow**:
  1. User selects "Add Plant"
  2. User browses plant catalog or uses identification
  3. User selects plant
  4. User enters plant name and initial health status
  5. User optionally uploads image
  6. System saves plant to collection

### UC4: Create Care Reminder
- **Actor**: User
- **Precondition**: User is logged in
- **Main Flow**:
  1. User navigates to Reminders
  2. User selects "Create Reminder"
  3. User optionally links to plant
  4. User sets reminder type and schedule
  5. User sets repeat frequency
  6. System saves reminder and schedules notification

### UC5: Place Order
- **Actor**: User
- **Precondition**: User is logged in, has items in cart
- **Main Flow**:
  1. User views shopping cart
  2. User proceeds to checkout
  3. User enters shipping address
  4. User reviews order
  5. User confirms payment
  6. System creates order
  7. User receives confirmation

---

# Chapter 4: Software Design

## 4.0 Introduction

This chapter presents the detailed software design of the Plantify application, including system architecture, database design, class design, and comprehensive UML diagrams that illustrate the system's structure and behavior.

## 4.1 System Architecture

The Plantify application follows a **three-tier architecture** consisting of the Presentation Layer (Mobile App), Business Logic Layer (Backend Services), and Data Layer (Database and Storage).

![System Architecture](diagrams/System%20architecture%20Diagram%20Plantify.png)

**Figure 4.1: System Architecture Diagram**

### Architecture Components:

**1. Flutter Mobile App (Client Tier)**
- **Presentation Layer**: Handles user interface and user interactions
- **Business Logic Layer**: Contains application logic, state management, and business rules
- **Data Layer**: Manages local caching, API communication, and data models

**2. Supabase Backend (Middleware Tier)**
- **Authentication Service**: Handles user registration, login, and session management
- **REST API**: Provides endpoints for all CRUD operations
- **Realtime Service**: Enables live updates and synchronization
- **Storage Service**: Manages file uploads and downloads (images, documents)

**3. AI Services**
- **Plant Disease Detection Model**: Analyzes plant images to identify diseases
- **Plant Identification Model**: Identifies plant species from images
- **Care Recommendation Engine**: Generates personalized care suggestions
- **Chatbot Assistant**: Provides natural language interaction for plant care questions

**4. Data Storage**
- **PostgreSQL Database**: Stores all structured data (users, plants, orders, etc.)
- **File Storage Buckets**: 
  - Plant Images (Public)
  - Product Images (Public)
  - User Uploads (Private)

### Data Flow:
1. User interactions trigger API calls from the mobile app
2. Backend services process requests and interact with the database
3. AI services process images and generate recommendations
4. Results are returned to the mobile app through the API
5. User interface updates reflect the changes

**Benefits of This Architecture:**
- **Separation of Concerns**: Clear boundaries between layers
- **Scalability**: Each tier can scale independently
- **Security**: Backend handles authentication and authorization
- **Performance**: Caching and optimization at each layer
- **Maintainability**: Changes in one layer don't affect others

---

## 4.2 Database Design

The database design follows a **relational database model** using PostgreSQL, ensuring data integrity, relationships, and efficient querying.

![ER Diagram](diagrams/ER%20Diagram%20Plantify.png)

**Figure 4.2: Entity Relationship Diagram**

### Database Schema Overview:

**Core Entities:**

1. **profiles** - User profile information
   - Primary Key: `id` (UUID, references auth.users)
   - Attributes: full_name, email, avatar_url, phone, address, city, zip_code, country
   - Relationship: One-to-many with user_plants, reminders, orders, gifts

2. **plants** - Master catalog of plant species
   - Primary Key: `id` (UUID)
   - Attributes: name, scientific_name, category, description, care_instructions (JSONB), image_url
   - Relationship: One-to-many with user_plants

3. **user_plants** - User's personal plant collection
   - Primary Key: `id` (UUID)
   - Foreign Keys: `user_id` (profiles), `plant_id` (plants)
   - Attributes: name, scientific_name, health_status, growth_percentage, next_watering_date, notes, image_url
   - Relationships: 
     - Many-to-one with profiles and plants
     - One-to-many with plant_health_history and reminders

4. **plant_health_history** - Historical health records
   - Primary Key: `id` (UUID)
   - Foreign Key: `user_plant_id` (user_plants)
   - Attributes: health_status, growth_percentage, notes, image_url, recorded_at
   - Purpose: Tracks plant health changes over time

5. **reminders** - Care reminder notifications
   - Primary Key: `id` (UUID)
   - Foreign Keys: `user_id` (profiles), `user_plant_id` (user_plants, optional)
   - Attributes: title, reminder_type, scheduled_time, repeat_frequency, tips, is_active, notification_id
   - Purpose: Manages automated care reminders

6. **products** - Marketplace product catalog
   - Primary Key: `id` (UUID)
   - Attributes: name, description, price, category, image_url, in_stock, stock_quantity
   - Relationship: One-to-many with order_items

7. **orders** - Customer orders
   - Primary Key: `id` (UUID)
   - Foreign Key: `user_id` (profiles)
   - Attributes: order_number, total_amount, shipping_address (JSONB), status, is_gift
   - Relationships: One-to-many with order_items, one-to-one with gifts

8. **order_items** - Individual items in orders
   - Primary Key: `id` (UUID)
   - Foreign Keys: `order_id` (orders), `product_id` (products)
   - Attributes: product_name, product_price, quantity, subtotal
   - Purpose: Stores order line items with snapshot data

9. **gifts** - Gift order information
   - Primary Key: `id` (UUID)
   - Foreign Keys: `order_id` (orders), `sender_id` (profiles)
   - Attributes: receiver_name, receiver_email, receiver_address (JSONB), gift_message, delivery_tracking
   - Purpose: Manages gift orders

### Key Design Decisions:

1. **Normalization**: Database is normalized to 3NF to eliminate redundancy
2. **JSONB Fields**: Used for flexible data (care_instructions, shipping_address) while maintaining queryability
3. **Foreign Key Constraints**: Ensure referential integrity with CASCADE and SET NULL options
4. **Indexes**: Created on foreign keys and frequently queried fields for performance
5. **Row-Level Security**: Implemented using Supabase RLS policies for data access control
6. **Timestamps**: Created_at and updated_at fields track data lifecycle

---

## 4.3 Class Design

The class diagram illustrates the object-oriented design of the application's domain models and their relationships.

![Class Diagram](diagrams/Class%20Diagram%20Plantify.png)

**Figure 4.3: Class Diagram**

### Core Classes:

**1. Profile Class**
- Represents user profile information
- Attributes: id, fullName, email, avatarUrl, phone, address, city
- Methods: `updateProfile()` - Updates user profile information

**2. Plant Class**
- Represents plant species from the master catalog
- Attributes: id, name, scientificName, category, description, careInstructions (Map), imageUrl
- Purpose: Provides reference data for plant species

**3. UserPlant Class**
- Represents a plant in user's collection
- Attributes: id, userId, plantId, name, healthStatus, growthPercentage, nextWateringDate, notes, imageUrl
- Methods: 
  - `updateHealth()` - Updates plant health status
  - `updateWateringDate()` - Sets next watering date
- Relationships: Belongs to Profile, references Plant

**4. PlantHealthHistory Class**
- Records historical health data for plants
- Attributes: id, userPlantId, healthStatus, growthPercentage, notes, imageUrl, recordedAt
- Purpose: Maintains timeline of plant health changes

**5. Reminder Class**
- Manages care reminders
- Attributes: id, userId, userPlantId, title, reminderType, scheduledTime, repeatFrequency, isActive
- Methods: 
  - `schedule()` - Schedules reminder notification
  - `cancel()` - Cancels active reminder
- Relationships: Belongs to Profile, optionally linked to UserPlant

**6. Product Class**
- Represents marketplace products
- Attributes: id, name, description, price, category, imageUrl, inStock, stockQuantity
- Purpose: Product catalog information

**7. Order Class**
- Represents customer orders
- Attributes: id, userId, orderNumber, totalAmount, shippingAddress (Map), status, isGift
- Methods: 
  - `calculateTotal()` - Computes order total
  - `cancel()` - Cancels order if possible
- Relationships: Belongs to Profile, contains OrderItems

**8. OrderItem Class**
- Represents individual items in an order
- Attributes: id, orderId, productId, productName, productPrice, quantity, subtotal
- Purpose: Stores order line items with price snapshots

**9. Gift Class**
- Manages gift order information
- Attributes: id, orderId, senderId, receiverName, receiverEmail, receiverAddress (Map), giftMessage, deliveryTracking
- Relationships: Linked to Order and Profile (sender)

### Relationship Patterns:
- **Composition**: Order contains OrderItems (1-to-many)
- **Aggregation**: Profile owns UserPlants (1-to-many)
- **Association**: UserPlant references Plant (many-to-one)
- **Optional Relationships**: Reminder can optionally link to UserPlant

---

## 4.4 Use Case Model

The use case diagram illustrates all the interactions between actors (users) and the system.

![Use Case Diagram](diagrams/Use%20Case%20Diagram%20Plantify.png)

**Figure 4.4: Use Case Diagram**

### Actors:

1. **User**: Primary actor who uses the application for plant care management
2. **Admin**: Secondary actor who manages products and system content

### Use Cases by Category:

**Authentication & Profile (UC1-UC4)**
- Register Account
- Login
- View Profile
- Update Profile

**Plant Discovery (UC5-UC7)**
- Browse Plants Catalog
- Search Plants
- View Plant Details

**Collection Management (UC8-UC11)**
- Add Plant to Collection
- View My Plants
- Update Plant Health
- Track Plant Growth

**Care Management (UC12-UC14)**
- Create Care Reminder
- View Reminders
- Complete Reminder

**Marketplace (UC15-UC19)**
- Browse Marketplace
- Add to Cart
- Place Order
- View Order History
- Send Plant as Gift

**Media & History (UC20-UC21)**
- Upload Plant Image
- View Plant History

### Relationship Types:
- **Extends**: Login extends to View Profile (user must be logged in)
- **Includes**: Add Plant to Collection includes View My Plants
- **Includes**: Place Order includes Add to Cart

This diagram helps identify all system functionalities and ensures comprehensive feature coverage.

---

## 4.5 Sequence Diagrams

Sequence diagrams illustrate the dynamic interactions between system components for key operations.

![Sequence Diagram](diagrams/Sequence%20Diagram%20Plantify.png)

**Figure 4.5: Sequence Diagram - All Use Cases**

### Key Scenarios Illustrated:

**1. Plant Disease Detection Flow:**
- User uploads image → UI sends to AI Service
- AI analyzes image → Returns disease result and recommendations
- User can save result to plant record

**2. Plant Identification Flow:**
- User takes photo → AI identifies species
- System displays plant information
- User can add identified plant to collection

**3. Add Plant to Collection Flow:**
- User provides plant data → PlantService processes
- API creates record in database
- Success response returned to user

**4. Update Plant Health Flow:**
- User updates health status
- System creates health history record
- Updates main plant record with new status

**5. Create Reminder Flow:**
- User creates reminder with details
- System saves to database
- Local notification scheduled

**6. Place Order Flow:**
- User browses products → Adds to cart
- Proceeds to checkout → Enters shipping info
- Order created with items
- Optional: Create gift record if gift order

### Interaction Patterns:
- **Synchronous Calls**: Most operations use request-response pattern
- **Async Processing**: AI analysis may take time
- **Error Handling**: All flows include error response paths
- **Data Validation**: Validation occurs at service layer before database operations

---

## 4.6 Activity Diagrams

Activity diagrams show the detailed workflows and decision points for various user activities. The following diagrams illustrate each major activity in the Plantify application.

### 4.6.1 Plant Disease Detection Activity

![Disease Detection Activity](diagrams/activity_01_disease_detection.puml)

**Figure 4.6.1: Plant Disease Detection Activity Diagram**

**Workflow Description:**
1. User opens disease detection feature
2. User captures or uploads plant image
3. AI model analyzes the image for disease patterns
4. System displays detection results with confidence scores
5. Treatment recommendations are shown
6. User can optionally save results to a plant record
7. If saved, plant health status is updated automatically

**Decision Points:**
- Whether to save results to plant record
- Confidence threshold for disease detection

---

### 4.6.2 Plant Identification Activity

![Plant Identification Activity](diagrams/Plant%20Identification%20Activity%20-%20Plantify.drawio.png)

**Figure 4.6.2: Plant Identification Activity Diagram**

**Workflow Description:**
1. User opens identification feature
2. User takes photo of unknown plant
3. AI model processes image and matches against plant database
4. System displays identified plant species information
5. Care instructions are shown
6. User can add identified plant to their collection

**Decision Points:**
- Whether to add identified plant to collection
- Accuracy threshold for identification

---

### 4.6.3 Add Plant to Collection Activity

![Add Plant Activity](diagrams/add_plant%20Activity%20Diagram%20Plantify.png)

**Figure 4.6.3: Add Plant to Collection Activity Diagram**

**Workflow Description:**
1. User opens add plant feature
2. User selects from catalog or uses identification
3. User enters plant name and sets initial health status
4. Optional: Upload plant image
5. Optional: Add scientific name
6. User sets initial growth percentage
7. System saves plant to user's collection

**Decision Points:**
- Source of plant (catalog vs identification)
- Whether to upload image
- Whether to add scientific name

---

### 4.6.4 Plant Care Tracking Activity

![Care Tracking Activity](diagrams/Care%20Tracking%20Activity%20Diagram.png)

**Figure 4.6.4: Plant Care Tracking Activity Diagram**

**Workflow Description:**
1. User opens plant details
2. Optionally updates health status with:
   - Health rating
   - Growth percentage
   - Notes (optional)
   - Images (optional)
3. Health history record is created
4. Optionally updates next watering date
5. User can view health history timeline
6. Updated information is displayed

**Decision Points:**
- Whether to update health status
- Whether to add notes/images
- Whether to update watering date
- Whether to view history

---

### 4.6.5 Create Care Reminder Activity

![Reminder Activity](diagrams/Reminder%20Activity%20Diagram%20Platify.png)

**Figure 4.6.5: Create Care Reminder Activity Diagram**

**Workflow Description:**
1. User opens reminders section
2. User creates new reminder
3. Optionally links reminder to specific plant
4. User sets reminder type (watering, fertilizing, pruning, etc.)
5. User sets scheduled time
6. User sets repeat frequency (Daily, Weekly, Once)
7. Optional: Add care tips
8. System saves reminder and schedules notification

**Decision Points:**
- Whether to link to specific plant
- Reminder type selection
- Repeat frequency
- Whether to add care tips

---

### 4.6.6 Marketplace & Orders Activity

![Marketplace Activity](diagrams/Market%20Place%20Activity%20Plantify.png)

**Figure 4.6.6: Marketplace & Orders Activity Diagram**

**Workflow Description:**
1. User opens marketplace
2. User views product catalog
3. Optional: Search or filter products
4. User views product details
5. User adds products to cart with quantities
6. User proceeds to checkout
7. User enters shipping address
8. User reviews and confirms order
9. System creates order and order items
10. Optional: If gift order, user enters receiver details and message
11. Order confirmation displayed

**Decision Points:**
- Whether to search/filter
- Whether to add to cart
- Whether to continue shopping or checkout
- Whether order is a gift
- Payment confirmation

---

### 4.6.7 View History Activity

![View History Activity](diagrams/View%20History%20Activity%20Plantify.png)

**Figure 4.6.7: View History Activity Diagram**

**Workflow Description:**
1. User opens history section
2. Optionally views plant health history:
   - Selects plant
   - Views health timeline
   - Optionally views specific record details
3. Optionally views order history:
   - Views order list
   - Optionally views order details
   - For gift orders, views tracking information

**Decision Points:**
- Type of history to view (plant vs order)
- Whether to view specific records/details
- Whether to track gift orders

**Benefits of Activity Diagrams:**
- Clear visualization of complex workflows
- Identification of all decision points
- Documentation of optional vs required steps
- Helps in identifying edge cases and error scenarios

---

## 4.7 Component Diagram

The component diagram illustrates the physical structure of the application, showing how different modules and services are organized.

![Component Diagram](diagrams/07_component_diagram.puml)

**Figure 4.7: Component Diagram**

### Component Organization:

**1. Presentation Layer**
- **UI Screens**: All user-facing screens (login, plant list, marketplace, etc.)
- **Widgets**: Reusable UI components (buttons, cards, forms, etc.)

**2. State Management**
- **Bloc/Provider**: State management solution handling app-wide state
- Manages user authentication state, plant collection state, cart state, etc.

**3. Business Logic Layer**
- **Plant Service**: Handles all plant-related operations
- **Order Service**: Manages order processing and marketplace logic
- **Reminder Service**: Handles reminder creation and notification scheduling
- **Profile Service**: Manages user profile operations

**4. Data Layer**
- **API Client**: Handles all HTTP requests to Supabase backend
- **Local Storage**: Manages offline data caching
- **Models**: Data transfer objects representing domain entities

**5. External Services**
- **Supabase Auth**: Authentication service
- **Supabase Database**: Database service
- **Supabase Storage**: File storage service
- **Notifications**: Local push notification service

### Component Interactions:
- UI Screens depend on Widgets for rendering
- State Management coordinates between UI and Services
- Services communicate with API Client
- API Client interacts with external Supabase services
- Models are used throughout all layers for data representation

**Benefits:**
- **Modularity**: Each component has a single responsibility
- **Reusability**: Components can be reused across different features
- **Testability**: Components can be tested independently
- **Maintainability**: Changes are localized to specific components

---

## 4.8 Deployment Diagram

The deployment diagram shows how the system is deployed across different hardware and network infrastructure.

![Deployment Diagram](diagrams/08_deployment_diagram.puml)

**Figure 4.8: Deployment Diagram**

### Deployment Architecture:

**1. Mobile Device**
- **Flutter App**: Installed on user's mobile device (iOS or Android)
- Components:
  - **UI**: User interface components
  - **Services**: Business logic services
  - **Local Cache**: Offline data storage

**2. Cloud Infrastructure (Supabase Platform)**
- **Authentication Server**: Handles user authentication requests
- **API Gateway**: Routes all API requests to appropriate services
- **Database Server**: PostgreSQL database storing all application data
- **Storage Server**: Manages file uploads and storage buckets
- **Realtime Server**: Handles WebSocket connections for live updates

**3. Internet**
- Communication medium connecting mobile devices to cloud services
- All communications use HTTPS for security

### Communication Flows:

1. **HTTPS Requests**: Mobile app → Internet → API Gateway → Database Server
2. **Authentication**: Mobile app → Internet → Authentication Server → Database Server
3. **File Operations**: Mobile app → Internet → Storage Server → Database Server (metadata)
4. **Realtime Updates**: Mobile app ↔ Internet ↔ Realtime Server (WebSocket)

### Deployment Characteristics:

**Mobile App:**
- Distributed to users via app stores (Google Play, Apple App Store)
- Installed locally on each device
- Supports offline functionality through local caching

**Backend Services:**
- Hosted on Supabase cloud infrastructure
- Scalable and managed by Supabase
- High availability and automatic backups

**Benefits:**
- **Scalability**: Cloud infrastructure scales automatically
- **Reliability**: Redundant servers ensure high uptime
- **Security**: HTTPS encryption for all communications
- **Performance**: CDN and caching optimize response times

---

## Summary

This chapter has presented a comprehensive software design for the Plantify application, covering:

1. **System Architecture**: Three-tier architecture with clear separation of concerns
2. **Database Design**: Normalized relational database with 9 core entities
3. **Class Design**: Object-oriented domain models with clear relationships
4. **Use Case Model**: 21 use cases covering all system functionalities
5. **Sequence Diagrams**: Detailed interaction flows for key operations
6. **Activity Diagrams**: 7 detailed workflows for major user activities
7. **Component Diagram**: Physical structure showing module organization
8. **Deployment Diagram**: Infrastructure and deployment architecture

These design artifacts provide a solid foundation for implementation and ensure all stakeholders have a clear understanding of the system's structure and behavior.

---

*End of Chapter 4*


