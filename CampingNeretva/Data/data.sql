USE [master]
GO
/****** Object:  Database [200012]    Script Date: 6/15/2025 4:38:23 PM ******/
CREATE DATABASE [200012]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'200012', FILENAME = N'/var/opt/mssql/data/200012.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'200012_log', FILENAME = N'/var/opt/mssql/data/200012_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [200012] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [200012].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [200012] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [200012] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [200012] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [200012] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [200012] SET ARITHABORT OFF 
GO
ALTER DATABASE [200012] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [200012] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [200012] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [200012] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [200012] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [200012] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [200012] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [200012] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [200012] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [200012] SET  DISABLE_BROKER 
GO
ALTER DATABASE [200012] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [200012] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [200012] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [200012] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [200012] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [200012] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [200012] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [200012] SET RECOVERY FULL 
GO
ALTER DATABASE [200012] SET  MULTI_USER 
GO
ALTER DATABASE [200012] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [200012] SET DB_CHAINING OFF 
GO
ALTER DATABASE [200012] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [200012] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [200012] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'200012', N'ON'
GO
ALTER DATABASE [200012] SET QUERY_STORE = ON
GO
ALTER DATABASE [200012] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [200012]
GO
/****** Object:  Table [dbo].[__EFMigrationsHistory]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[__EFMigrationsHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AccommodationImages]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccommodationImages](
	[AccommodationImageId] [int] IDENTITY(1,1) NOT NULL,
	[AccommodationId] [int] NOT NULL,
	[ImageId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AccommodationImageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Accommodations]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Accommodations](
	[AccommodationId] [int] IDENTITY(1,1) NOT NULL,
	[Type] [nvarchar](max) NOT NULL,
	[PricePerNight] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK__Accommod__DBB30A518EBF438C] PRIMARY KEY CLUSTERED 
(
	[AccommodationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Activities]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Activities](
	[ActivityId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](max) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[Date] [datetime] NOT NULL,
	[Price] [decimal](18, 2) NOT NULL,
	[FacilityId] [int] NULL,
 CONSTRAINT [PK__Activiti__45F4A791551271B0] PRIMARY KEY CLUSTERED 
(
	[ActivityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ActivityImages]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActivityImages](
	[ActivityImageId] [int] IDENTITY(1,1) NOT NULL,
	[ActivityId] [int] NOT NULL,
	[ImageId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ActivityImageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ActivityWorkers]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActivityWorkers](
	[ActivityId] [int] NOT NULL,
	[WorkerId] [int] NOT NULL,
 CONSTRAINT [PK__Activity__35836F130254DC34] PRIMARY KEY CLUSTERED 
(
	[ActivityId] ASC,
	[WorkerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Facilities]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Facilities](
	[FacilityId] [int] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[FacilityType] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK__Faciliti__5FB08A74FF9A6D7B] PRIMARY KEY CLUSTERED 
(
	[FacilityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FacilityImages]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FacilityImages](
	[FacilityImageId] [int] IDENTITY(1,1) NOT NULL,
	[FacilityId] [int] NOT NULL,
	[ImageId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[FacilityImageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Images]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Images](
	[ImageId] [int] IDENTITY(1,1) NOT NULL,
	[Path] [nvarchar](max) NOT NULL,
	[DateCreated] [datetime2](7) NULL,
	[ContentType] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[ImageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ParcelAccommodations]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ParcelAccommodations](
	[ParcelAccommodationId] [int] IDENTITY(1,1) NOT NULL,
	[ParcelAccommodation] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[ParcelAccommodationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ParcelImages]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ParcelImages](
	[ParcelImageId] [int] IDENTITY(1,1) NOT NULL,
	[ParcelId] [int] NOT NULL,
	[ImageId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ParcelImageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Parcels]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Parcels](
	[ParcelId] [int] IDENTITY(1,1) NOT NULL,
	[ParcelNumber] [int] NOT NULL,
	[Shade] [bit] NOT NULL,
	[Electricity] [bit] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[AvailabilityStatus] [bit] NOT NULL,
	[ParcelAccommodationId] [int] NULL,
	[ParcelTypeId] [int] NULL,
 CONSTRAINT [PK__Parcels__B5F2167B0DA861B2] PRIMARY KEY CLUSTERED 
(
	[ParcelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ParcelTypes]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ParcelTypes](
	[ParcelTypeId] [int] IDENTITY(1,1) NOT NULL,
	[ParcelType] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[ParcelTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Payments]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Payments](
	[PaymentId] [int] IDENTITY(1,1) NOT NULL,
	[ReservationId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[Amount] [decimal](18, 2) NOT NULL,
	[TransactionDate] [datetime] NOT NULL,
	[PayPalOrderId] [nvarchar](255) NULL,
	[PayPalPaymentId] [nvarchar](255) NULL,
	[Status] [nvarchar](50) NULL,
 CONSTRAINT [PK__Payments__9B556A3894676AAF] PRIMARY KEY CLUSTERED 
(
	[PaymentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PersonImages]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersonImages](
	[PersonImageId] [int] IDENTITY(1,1) NOT NULL,
	[PersonId] [int] NOT NULL,
	[ImageId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PersonImageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Persons]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Persons](
	[PersonId] [int] IDENTITY(1,1) NOT NULL,
	[Type] [nvarchar](max) NOT NULL,
	[PricePerNight] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK__Persons__AA2FFBE58994B53E] PRIMARY KEY CLUSTERED 
(
	[PersonId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RentableItemImages]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RentableItemImages](
	[RentableItemImageId] [int] IDENTITY(1,1) NOT NULL,
	[RentableItemId] [int] NOT NULL,
	[ImageId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RentableItemImageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RentableItems]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RentableItems](
	[ItemId] [int] IDENTITY(1,1) NOT NULL,
	[TotalQuantity] [int] NOT NULL,
	[Name] [nvarchar](max) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[PricePerDay] [decimal](18, 2) NOT NULL,
	[AvailableQuantity] [int] NULL,
 CONSTRAINT [PK__Rentable__727E838B778586B3] PRIMARY KEY CLUSTERED 
(
	[ItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReservationAccommodations]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReservationAccommodations](
	[ReservationId] [int] NOT NULL,
	[AccommodationId] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
 CONSTRAINT [PK__Reservat__BA556F81D6DFD313] PRIMARY KEY CLUSTERED 
(
	[ReservationId] ASC,
	[AccommodationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReservationActivities]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReservationActivities](
	[ReservationId] [int] NOT NULL,
	[ActivityId] [int] NOT NULL,
 CONSTRAINT [PK__Reservat__B3B1155DA7C583C9] PRIMARY KEY CLUSTERED 
(
	[ReservationId] ASC,
	[ActivityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReservationPersons]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReservationPersons](
	[ReservationId] [int] NOT NULL,
	[PersonId] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
 CONSTRAINT [PK__Reservat__FD4CA09AC6619247] PRIMARY KEY CLUSTERED 
(
	[ReservationId] ASC,
	[PersonId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReservationRentables]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReservationRentables](
	[ReservationId] [int] NOT NULL,
	[ItemId] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
 CONSTRAINT [PK__Reservat__10C9B71CA8B98473] PRIMARY KEY CLUSTERED 
(
	[ReservationId] ASC,
	[ItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Reservations]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reservations](
	[ReservationId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[ParcelId] [int] NOT NULL,
	[CheckInDate] [datetime] NOT NULL,
	[CheckOutDate] [datetime] NOT NULL,
	[TotalPrice] [decimal](18, 2) NOT NULL,
	[PaymentStatus] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK__Reservat__B7EE5F243AA4F869] PRIMARY KEY CLUSTERED 
(
	[ReservationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReservationVehicles]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReservationVehicles](
	[ReservationId] [int] NOT NULL,
	[VehicleId] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
 CONSTRAINT [PK__Reservat__8398EA6D3FB216E2] PRIMARY KEY CLUSTERED 
(
	[ReservationId] ASC,
	[VehicleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Reviews]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reviews](
	[ReviewId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[WorkerId] [int] NOT NULL,
	[Rating] [int] NOT NULL,
	[Comment] [nvarchar](max) NOT NULL,
	[DatePosted] [datetime] NOT NULL,
 CONSTRAINT [PK__Reviews__74BC79CE711461F2] PRIMARY KEY CLUSTERED 
(
	[ReviewId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Roles]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[RoleId] [int] IDENTITY(1,1) NOT NULL,
	[RoleName] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK__Roles__8AFACE1A7F60ED59] PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserPreference]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserPreference](
	[UserPreferenceId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[NumberOfPeople] [int] NOT NULL,
	[HasSmallChildren] [bit] NOT NULL,
	[HasSeniorTravelers] [bit] NOT NULL,
	[CarLength] [nvarchar](50) NOT NULL,
	[HasDogs] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UserPreferenceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserRecommendations]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRecommendations](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[ParcelId1] [int] NULL,
	[ParcelId2] [int] NULL,
	[ParcelId3] [int] NULL,
	[ActivityId1] [int] NULL,
	[ActivityId2] [int] NULL,
	[RentableItemId1] [int] NULL,
	[RentableItemId2] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](max) NOT NULL,
	[LastName] [nvarchar](max) NOT NULL,
	[Email] [nvarchar](max) NOT NULL,
	[PasswordHash] [nvarchar](max) NOT NULL,
	[PhoneNumber] [nvarchar](max) NULL,
	[PasswordSalt] [nvarchar](max) NOT NULL,
	[UserName] [nvarchar](max) NOT NULL,
	[UserTypeId] [int] NOT NULL,
 CONSTRAINT [PK__Users__1788CC4CFDA4BE49] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserType]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserType](
	[UserTypeId] [int] IDENTITY(1,1) NOT NULL,
	[TypeName] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK__UserType__40D2D81612345678] PRIMARY KEY CLUSTERED 
(
	[UserTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VehicleImages]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VehicleImages](
	[VehicleImageId] [int] IDENTITY(1,1) NOT NULL,
	[VehicleId] [int] NOT NULL,
	[ImageId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[VehicleImageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Vehicles]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Vehicles](
	[VehicleId] [int] IDENTITY(1,1) NOT NULL,
	[Type] [nvarchar](max) NOT NULL,
	[PricePerNight] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK__Vehicles__476B54927D223A98] PRIMARY KEY CLUSTERED 
(
	[VehicleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkerRoles]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkerRoles](
	[WorkerId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
 CONSTRAINT [PK__WorkerRo__E1A8630F89ABCDEF] PRIMARY KEY CLUSTERED 
(
	[WorkerId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Workers]    Script Date: 6/15/2025 4:38:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Workers](
	[WorkerId] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](max) NOT NULL,
	[LastName] [nvarchar](max) NOT NULL,
	[PhoneNumber] [nvarchar](max) NOT NULL,
	[Email] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK__Workers__077C8826ADEFBF7D] PRIMARY KEY CLUSTERED 
(
	[WorkerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20250225194622_InitialCreate', N'9.0.2')
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20250225194833_AddUserPasswordSaltAndUserName', N'9.0.2')
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20250225203532_AddFacilityType', N'9.0.2')
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20250226134408_AddRole', N'9.0.2')
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20250228173802_AddUserType', N'9.0.2')
GO
SET IDENTITY_INSERT [dbo].[AccommodationImages] ON 

INSERT [dbo].[AccommodationImages] ([AccommodationImageId], [AccommodationId], [ImageId]) VALUES (28, 1, 194)
INSERT [dbo].[AccommodationImages] ([AccommodationImageId], [AccommodationId], [ImageId]) VALUES (29, 2, 194)
INSERT [dbo].[AccommodationImages] ([AccommodationImageId], [AccommodationId], [ImageId]) VALUES (30, 5, 194)
INSERT [dbo].[AccommodationImages] ([AccommodationImageId], [AccommodationId], [ImageId]) VALUES (31, 6, 194)
SET IDENTITY_INSERT [dbo].[AccommodationImages] OFF
GO
SET IDENTITY_INSERT [dbo].[Accommodations] ON 

INSERT [dbo].[Accommodations] ([AccommodationId], [Type], [PricePerNight]) VALUES (1, N'Tent', CAST(5.00 AS Decimal(18, 2)))
INSERT [dbo].[Accommodations] ([AccommodationId], [Type], [PricePerNight]) VALUES (2, N'Caravan', CAST(20.00 AS Decimal(18, 2)))
INSERT [dbo].[Accommodations] ([AccommodationId], [Type], [PricePerNight]) VALUES (5, N'Bungalow', CAST(50.00 AS Decimal(18, 2)))
INSERT [dbo].[Accommodations] ([AccommodationId], [Type], [PricePerNight]) VALUES (6, N'vehicle', CAST(0.00 AS Decimal(18, 2)))
SET IDENTITY_INSERT [dbo].[Accommodations] OFF
GO
SET IDENTITY_INSERT [dbo].[Activities] ON 

INSERT [dbo].[Activities] ([ActivityId], [Name], [Description], [Date], [Price], [FacilityId]) VALUES (6, N'beer party', N'Party? Beer? All free for we are clebrating campsides birthday!!', CAST(N'2025-08-20T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[Activities] ([ActivityId], [Name], [Description], [Date], [Price], [FacilityId]) VALUES (7, N'Grill party', N'We nare preparing some of famous Bosnian grills, join us!', CAST(N'2025-06-28T00:00:00.000' AS DateTime), CAST(20.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[Activities] ([ActivityId], [Name], [Description], [Date], [Price], [FacilityId]) VALUES (9, N'Rafting', N'enjoy cruising down the coldest river of europe called Neretva, the green beauty of Mostar!', CAST(N'2025-07-02T00:00:00.000' AS DateTime), CAST(35.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[Activities] ([ActivityId], [Name], [Description], [Date], [Price], [FacilityId]) VALUES (12, N'campfire', N'1', CAST(N'2025-06-15T00:00:00.000' AS DateTime), CAST(10.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[Activities] ([ActivityId], [Name], [Description], [Date], [Price], [FacilityId]) VALUES (13, N'Visit Ruište', N'2', CAST(N'2025-06-15T00:00:00.000' AS DateTime), CAST(10.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[Activities] ([ActivityId], [Name], [Description], [Date], [Price], [FacilityId]) VALUES (14, N'Visit Fortica', N'3', CAST(N'2025-06-16T00:00:00.000' AS DateTime), CAST(10.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[Activities] ([ActivityId], [Name], [Description], [Date], [Price], [FacilityId]) VALUES (15, N'Zipline', N'4', CAST(N'2025-06-15T00:00:00.000' AS DateTime), CAST(10.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[Activities] ([ActivityId], [Name], [Description], [Date], [Price], [FacilityId]) VALUES (16, N'Visit Kravice', N'5', CAST(N'2025-06-17T00:00:00.000' AS DateTime), CAST(10.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[Activities] ([ActivityId], [Name], [Description], [Date], [Price], [FacilityId]) VALUES (17, N'Visit Blagaj', N'6', CAST(N'2025-06-15T00:00:00.000' AS DateTime), CAST(10.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[Activities] ([ActivityId], [Name], [Description], [Date], [Price], [FacilityId]) VALUES (18, N'Mostar tour', N'7', CAST(N'2025-06-25T00:00:00.000' AS DateTime), CAST(10.00 AS Decimal(18, 2)), NULL)
SET IDENTITY_INSERT [dbo].[Activities] OFF
GO
SET IDENTITY_INSERT [dbo].[ActivityImages] ON 

INSERT [dbo].[ActivityImages] ([ActivityImageId], [ActivityId], [ImageId]) VALUES (82, 6, 194)
INSERT [dbo].[ActivityImages] ([ActivityImageId], [ActivityId], [ImageId]) VALUES (83, 7, 194)
INSERT [dbo].[ActivityImages] ([ActivityImageId], [ActivityId], [ImageId]) VALUES (84, 9, 194)
INSERT [dbo].[ActivityImages] ([ActivityImageId], [ActivityId], [ImageId]) VALUES (85, 12, 194)
INSERT [dbo].[ActivityImages] ([ActivityImageId], [ActivityId], [ImageId]) VALUES (86, 13, 194)
INSERT [dbo].[ActivityImages] ([ActivityImageId], [ActivityId], [ImageId]) VALUES (87, 14, 194)
INSERT [dbo].[ActivityImages] ([ActivityImageId], [ActivityId], [ImageId]) VALUES (88, 15, 194)
INSERT [dbo].[ActivityImages] ([ActivityImageId], [ActivityId], [ImageId]) VALUES (89, 16, 194)
INSERT [dbo].[ActivityImages] ([ActivityImageId], [ActivityId], [ImageId]) VALUES (90, 17, 194)
INSERT [dbo].[ActivityImages] ([ActivityImageId], [ActivityId], [ImageId]) VALUES (91, 18, 194)
SET IDENTITY_INSERT [dbo].[ActivityImages] OFF
GO
SET IDENTITY_INSERT [dbo].[Facilities] ON 

INSERT [dbo].[Facilities] ([FacilityId], [Description], [FacilityType]) VALUES (1, N'a nice place for a drink with your friends at the beatifull beach on the ice cold river Neretva of Mostar', N'Bar')
INSERT [dbo].[Facilities] ([FacilityId], [Description], [FacilityType]) VALUES (2, N'a nice little fireplace for grilling meat with your friends and family', N'Fireplace')
INSERT [dbo].[Facilities] ([FacilityId], [Description], [FacilityType]) VALUES (4, N'at the end of our campside there is a nice little facility meant for all you hygiene needs', N'Sanitaries')
INSERT [dbo].[Facilities] ([FacilityId], [Description], [FacilityType]) VALUES (7, N'Private little beach right on the Neretva river, perfect for relaxing and cooling off', N'Beach')
SET IDENTITY_INSERT [dbo].[Facilities] OFF
GO
SET IDENTITY_INSERT [dbo].[FacilityImages] ON 

INSERT [dbo].[FacilityImages] ([FacilityImageId], [FacilityId], [ImageId]) VALUES (23, 1, 195)
INSERT [dbo].[FacilityImages] ([FacilityImageId], [FacilityId], [ImageId]) VALUES (24, 2, 195)
INSERT [dbo].[FacilityImages] ([FacilityImageId], [FacilityId], [ImageId]) VALUES (25, 4, 195)
INSERT [dbo].[FacilityImages] ([FacilityImageId], [FacilityId], [ImageId]) VALUES (26, 7, 195)
SET IDENTITY_INSERT [dbo].[FacilityImages] OFF
GO
SET IDENTITY_INSERT [dbo].[Images] ON 

INSERT [dbo].[Images] ([ImageId], [Path], [DateCreated], [ContentType]) VALUES (193, N'/uploads/images/8768767f-4bbf-4413-ac78-a599e0c29a91_parcel1 (1)_11zon.png', CAST(N'2025-06-15T15:26:17.6018503' AS DateTime2), N'image/png')
INSERT [dbo].[Images] ([ImageId], [Path], [DateCreated], [ContentType]) VALUES (194, N'/uploads/images/23c303c0-798a-41ba-bc7d-4f2a7c5fe86b_dollar_11zon.png', CAST(N'2025-06-15T15:32:59.3786621' AS DateTime2), N'image/png')
INSERT [dbo].[Images] ([ImageId], [Path], [DateCreated], [ContentType]) VALUES (195, N'/uploads/images/11d8dd99-70ff-448c-9a60-703f7652db05_fireplace (1)_11zon.png', CAST(N'2025-06-15T15:38:24.0466055' AS DateTime2), N'image/png')
SET IDENTITY_INSERT [dbo].[Images] OFF
GO
SET IDENTITY_INSERT [dbo].[ParcelAccommodations] ON 

INSERT [dbo].[ParcelAccommodations] ([ParcelAccommodationId], [ParcelAccommodation]) VALUES (4, N'tent')
INSERT [dbo].[ParcelAccommodations] ([ParcelAccommodationId], [ParcelAccommodation]) VALUES (5, N'motohome')
INSERT [dbo].[ParcelAccommodations] ([ParcelAccommodationId], [ParcelAccommodation]) VALUES (6, N'van')
INSERT [dbo].[ParcelAccommodations] ([ParcelAccommodationId], [ParcelAccommodation]) VALUES (8, N'truck')
SET IDENTITY_INSERT [dbo].[ParcelAccommodations] OFF
GO
SET IDENTITY_INSERT [dbo].[ParcelImages] ON 

INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (117, 1, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (118, 2, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (119, 3, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (120, 17, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (121, 18, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (122, 20, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (123, 23, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (124, 24, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (125, 25, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (126, 26, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (127, 27, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (128, 28, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (129, 29, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (130, 30, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (131, 31, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (132, 32, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (133, 33, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (134, 34, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (135, 35, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (136, 36, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (137, 37, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (138, 38, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (139, 39, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (140, 40, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (141, 41, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (142, 42, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (143, 43, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (144, 44, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (145, 45, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (146, 46, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (147, 47, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (148, 48, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (149, 49, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (150, 50, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (151, 51, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (152, 52, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (153, 53, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (154, 54, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (155, 55, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (156, 56, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (157, 57, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (158, 58, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (159, 59, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (160, 60, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (161, 61, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (162, 62, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (163, 63, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (164, 64, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (165, 65, 193)
INSERT [dbo].[ParcelImages] ([ParcelImageId], [ParcelId], [ImageId]) VALUES (166, 66, 193)
SET IDENTITY_INSERT [dbo].[ParcelImages] OFF
GO
SET IDENTITY_INSERT [dbo].[Parcels] ON 

INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (1, 1, 1, 0, N'parcela', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (2, 2, 0, 1, N'parcela', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (3, 3, 1, 1, N'parcela', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (17, 4, 0, 0, N'parcela', 1, 6, 3)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (18, 5, 0, 1, N'parcela', 1, 5, 7)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (20, 6, 0, 1, N'parcela', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (23, 7, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (24, 8, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (25, 9, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (26, 10, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (27, 11, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (28, 12, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (29, 13, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (30, 14, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (31, 15, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (32, 16, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (33, 17, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (34, 18, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (35, 19, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (36, 20, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (37, 21, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (38, 22, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (39, 23, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (40, 24, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (41, 25, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (42, 26, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (43, 27, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (44, 28, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (45, 29, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (46, 30, 1, 1, N'aaaa', 1, 5, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (47, 31, 1, 1, N'aaaa', 1, 5, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (48, 32, 1, 1, N'aaaa', 1, 5, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (49, 33, 1, 1, N'aaaa', 1, 5, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (50, 34, 1, 1, N'aaaa', 1, 5, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (51, 35, 1, 1, N'aaaa', 1, 6, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (52, 36, 1, 1, N'aaaa', 1, 6, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (53, 37, 1, 0, N'aaaa', 1, 6, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (54, 38, 0, 1, N'aaaa', 1, 6, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (55, 39, 0, 1, N'aaaa', 1, 8, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (56, 40, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (57, 41, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (58, 42, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (59, 43, 0, 0, N'aaaa', 1, 8, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (60, 44, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (61, 45, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (62, 46, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (63, 47, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (64, 48, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (65, 49, 1, 1, N'aaaa', 1, 4, 2)
INSERT [dbo].[Parcels] ([ParcelId], [ParcelNumber], [Shade], [Electricity], [Description], [AvailabilityStatus], [ParcelAccommodationId], [ParcelTypeId]) VALUES (66, 50, 1, 1, N'aaaa', 1, 4, 2)
SET IDENTITY_INSERT [dbo].[Parcels] OFF
GO
SET IDENTITY_INSERT [dbo].[ParcelTypes] ON 

INSERT [dbo].[ParcelTypes] ([ParcelTypeId], [ParcelType]) VALUES (2, N'grass')
INSERT [dbo].[ParcelTypes] ([ParcelTypeId], [ParcelType]) VALUES (3, N'gravel')
INSERT [dbo].[ParcelTypes] ([ParcelTypeId], [ParcelType]) VALUES (7, N'Sand')
SET IDENTITY_INSERT [dbo].[ParcelTypes] OFF
GO
SET IDENTITY_INSERT [dbo].[Payments] ON 

INSERT [dbo].[Payments] ([PaymentId], [ReservationId], [UserId], [Amount], [TransactionDate], [PayPalOrderId], [PayPalPaymentId], [Status]) VALUES (61, 99, 40, CAST(53.00 AS Decimal(18, 2)), CAST(N'2025-06-14T18:31:39.720' AS DateTime), N'1WB60703MM602845R', N'3D372534WE173470Y', N'COMPLETED')
INSERT [dbo].[Payments] ([PaymentId], [ReservationId], [UserId], [Amount], [TransactionDate], [PayPalOrderId], [PayPalPaymentId], [Status]) VALUES (62, 100, 40, CAST(35.00 AS Decimal(18, 2)), CAST(N'2025-06-14T18:44:47.120' AS DateTime), N'82H358536P029060C', N'0WS813321T508461G', N'COMPLETED')
INSERT [dbo].[Payments] ([PaymentId], [ReservationId], [UserId], [Amount], [TransactionDate], [PayPalOrderId], [PayPalPaymentId], [Status]) VALUES (63, 101, 41, CAST(110.00 AS Decimal(18, 2)), CAST(N'2025-06-14T18:47:01.937' AS DateTime), N'5N140417H2456310N', N'32K48197UB688130E', N'COMPLETED')
INSERT [dbo].[Payments] ([PaymentId], [ReservationId], [UserId], [Amount], [TransactionDate], [PayPalOrderId], [PayPalPaymentId], [Status]) VALUES (64, 102, 41, CAST(70.00 AS Decimal(18, 2)), CAST(N'2025-06-14T18:47:46.237' AS DateTime), N'0XX5541234016273P', N'0YL07632TM2331516', N'COMPLETED')
INSERT [dbo].[Payments] ([PaymentId], [ReservationId], [UserId], [Amount], [TransactionDate], [PayPalOrderId], [PayPalPaymentId], [Status]) VALUES (65, 103, 41, CAST(48.00 AS Decimal(18, 2)), CAST(N'2025-06-14T18:48:24.817' AS DateTime), N'6TL92659CJ508984U', N'42V55647VY215343P', N'COMPLETED')
INSERT [dbo].[Payments] ([PaymentId], [ReservationId], [UserId], [Amount], [TransactionDate], [PayPalOrderId], [PayPalPaymentId], [Status]) VALUES (66, 104, 42, CAST(110.00 AS Decimal(18, 2)), CAST(N'2025-06-14T18:50:25.160' AS DateTime), N'86C1790595166374X', N'02C2414552859411U', N'COMPLETED')
INSERT [dbo].[Payments] ([PaymentId], [ReservationId], [UserId], [Amount], [TransactionDate], [PayPalOrderId], [PayPalPaymentId], [Status]) VALUES (67, 105, 42, CAST(70.00 AS Decimal(18, 2)), CAST(N'2025-06-14T18:51:06.190' AS DateTime), N'17U52684MX8621724', N'3PD14429LB551353E', N'COMPLETED')
INSERT [dbo].[Payments] ([PaymentId], [ReservationId], [UserId], [Amount], [TransactionDate], [PayPalOrderId], [PayPalPaymentId], [Status]) VALUES (68, 106, 42, CAST(415.00 AS Decimal(18, 2)), CAST(N'2025-06-14T18:51:56.230' AS DateTime), N'2S512490K2343873T', N'7GY20774AC745640T', N'COMPLETED')
INSERT [dbo].[Payments] ([PaymentId], [ReservationId], [UserId], [Amount], [TransactionDate], [PayPalOrderId], [PayPalPaymentId], [Status]) VALUES (69, 107, 43, CAST(138.00 AS Decimal(18, 2)), CAST(N'2025-06-14T18:53:51.557' AS DateTime), N'1C441270U09644112', N'1KK43499G72971540', N'COMPLETED')
INSERT [dbo].[Payments] ([PaymentId], [ReservationId], [UserId], [Amount], [TransactionDate], [PayPalOrderId], [PayPalPaymentId], [Status]) VALUES (70, 108, 43, CAST(35.00 AS Decimal(18, 2)), CAST(N'2025-06-14T18:54:25.383' AS DateTime), N'31987708S7005915M', N'7TG48398680829329', N'COMPLETED')
INSERT [dbo].[Payments] ([PaymentId], [ReservationId], [UserId], [Amount], [TransactionDate], [PayPalOrderId], [PayPalPaymentId], [Status]) VALUES (71, 109, 44, CAST(65.00 AS Decimal(18, 2)), CAST(N'2025-06-14T18:56:07.167' AS DateTime), N'83N502972Y152902R', N'9HH50983SL559832W', N'COMPLETED')
INSERT [dbo].[Payments] ([PaymentId], [ReservationId], [UserId], [Amount], [TransactionDate], [PayPalOrderId], [PayPalPaymentId], [Status]) VALUES (72, 110, 44, CAST(38.00 AS Decimal(18, 2)), CAST(N'2025-06-14T18:56:42.467' AS DateTime), N'9WL40636CW639613F', N'85718989U0174212U', N'COMPLETED')
INSERT [dbo].[Payments] ([PaymentId], [ReservationId], [UserId], [Amount], [TransactionDate], [PayPalOrderId], [PayPalPaymentId], [Status]) VALUES (73, 111, 45, CAST(113.00 AS Decimal(18, 2)), CAST(N'2025-06-14T19:02:48.140' AS DateTime), N'0GK291285R595004Y', NULL, N'PENDING')
INSERT [dbo].[Payments] ([PaymentId], [ReservationId], [UserId], [Amount], [TransactionDate], [PayPalOrderId], [PayPalPaymentId], [Status]) VALUES (74, 112, 46, CAST(50.00 AS Decimal(18, 2)), CAST(N'2025-06-14T19:06:51.800' AS DateTime), N'9Y409041RU905724G', N'88472368AM2047405', N'COMPLETED')
INSERT [dbo].[Payments] ([PaymentId], [ReservationId], [UserId], [Amount], [TransactionDate], [PayPalOrderId], [PayPalPaymentId], [Status]) VALUES (75, 113, 47, CAST(70.00 AS Decimal(18, 2)), CAST(N'2025-06-14T19:10:30.040' AS DateTime), N'3MB33085H1911025P', N'8BW25247H6937292T', N'COMPLETED')
INSERT [dbo].[Payments] ([PaymentId], [ReservationId], [UserId], [Amount], [TransactionDate], [PayPalOrderId], [PayPalPaymentId], [Status]) VALUES (76, 114, 47, CAST(45.00 AS Decimal(18, 2)), CAST(N'2025-06-14T19:11:04.443' AS DateTime), N'1JK90022DJ159081K', N'18V523702M7141108', N'COMPLETED')
INSERT [dbo].[Payments] ([PaymentId], [ReservationId], [UserId], [Amount], [TransactionDate], [PayPalOrderId], [PayPalPaymentId], [Status]) VALUES (77, 116, 43, CAST(70.00 AS Decimal(18, 2)), CAST(N'2025-06-14T21:21:23.100' AS DateTime), N'2X1313097F294125P', N'3YE63906NC6776430', N'COMPLETED')
INSERT [dbo].[Payments] ([PaymentId], [ReservationId], [UserId], [Amount], [TransactionDate], [PayPalOrderId], [PayPalPaymentId], [Status]) VALUES (78, 117, 43, CAST(45.00 AS Decimal(18, 2)), CAST(N'2025-06-14T21:40:23.677' AS DateTime), N'89D84189HS865862N', N'13T711410S5798526', N'COMPLETED')
INSERT [dbo].[Payments] ([PaymentId], [ReservationId], [UserId], [Amount], [TransactionDate], [PayPalOrderId], [PayPalPaymentId], [Status]) VALUES (79, 121, 43, CAST(20.00 AS Decimal(18, 2)), CAST(N'2025-06-14T22:36:00.717' AS DateTime), N'28B31065M8113313T', N'3MF06626PS7558745', N'COMPLETED')
SET IDENTITY_INSERT [dbo].[Payments] OFF
GO
SET IDENTITY_INSERT [dbo].[PersonImages] ON 

INSERT [dbo].[PersonImages] ([PersonImageId], [PersonId], [ImageId]) VALUES (23, 1, 194)
INSERT [dbo].[PersonImages] ([PersonImageId], [PersonId], [ImageId]) VALUES (24, 2, 194)
SET IDENTITY_INSERT [dbo].[PersonImages] OFF
GO
SET IDENTITY_INSERT [dbo].[Persons] ON 

INSERT [dbo].[Persons] ([PersonId], [Type], [PricePerNight]) VALUES (1, N'Adult', CAST(5.00 AS Decimal(18, 2)))
INSERT [dbo].[Persons] ([PersonId], [Type], [PricePerNight]) VALUES (2, N'Kids', CAST(3.00 AS Decimal(18, 2)))
SET IDENTITY_INSERT [dbo].[Persons] OFF
GO
SET IDENTITY_INSERT [dbo].[RentableItemImages] ON 

INSERT [dbo].[RentableItemImages] ([RentableItemImageId], [RentableItemId], [ImageId]) VALUES (44, 1, 194)
INSERT [dbo].[RentableItemImages] ([RentableItemImageId], [RentableItemId], [ImageId]) VALUES (45, 2, 194)
INSERT [dbo].[RentableItemImages] ([RentableItemImageId], [RentableItemId], [ImageId]) VALUES (46, 6, 194)
INSERT [dbo].[RentableItemImages] ([RentableItemImageId], [RentableItemId], [ImageId]) VALUES (47, 7, 194)
INSERT [dbo].[RentableItemImages] ([RentableItemImageId], [RentableItemId], [ImageId]) VALUES (48, 8, 194)
INSERT [dbo].[RentableItemImages] ([RentableItemImageId], [RentableItemId], [ImageId]) VALUES (49, 9, 194)
INSERT [dbo].[RentableItemImages] ([RentableItemImageId], [RentableItemId], [ImageId]) VALUES (50, 10, 194)
INSERT [dbo].[RentableItemImages] ([RentableItemImageId], [RentableItemId], [ImageId]) VALUES (51, 11, 194)
INSERT [dbo].[RentableItemImages] ([RentableItemImageId], [RentableItemId], [ImageId]) VALUES (52, 12, 194)
INSERT [dbo].[RentableItemImages] ([RentableItemImageId], [RentableItemId], [ImageId]) VALUES (53, 13, 194)
SET IDENTITY_INSERT [dbo].[RentableItemImages] OFF
GO
SET IDENTITY_INSERT [dbo].[RentableItems] ON 

INSERT [dbo].[RentableItems] ([ItemId], [TotalQuantity], [Name], [Description], [PricePerDay], [AvailableQuantity]) VALUES (1, 20, N'bycicle', N'bycicle for visiting mostar!', CAST(10.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[RentableItems] ([ItemId], [TotalQuantity], [Name], [Description], [PricePerDay], [AvailableQuantity]) VALUES (2, 20, N'fishing rod', N'rod for fishing in Neretva river', CAST(10.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[RentableItems] ([ItemId], [TotalQuantity], [Name], [Description], [PricePerDay], [AvailableQuantity]) VALUES (6, 5, N'Motorbike', N'Motorbikes for quick access to Mostar', CAST(30.00 AS Decimal(18, 2)), 3)
INSERT [dbo].[RentableItems] ([ItemId], [TotalQuantity], [Name], [Description], [PricePerDay], [AvailableQuantity]) VALUES (7, 2, N'car', N'Cars for safe travels around Mostar', CAST(40.00 AS Decimal(18, 2)), 11)
INSERT [dbo].[RentableItems] ([ItemId], [TotalQuantity], [Name], [Description], [PricePerDay], [AvailableQuantity]) VALUES (8, 10, N'Tent', N'Dont have a tent but want to sleep in our nature? We have a tent for you!', CAST(10.00 AS Decimal(18, 2)), 10)
INSERT [dbo].[RentableItems] ([ItemId], [TotalQuantity], [Name], [Description], [PricePerDay], [AvailableQuantity]) VALUES (9, 10, N'Gas stove', N'Need something to heat up your dinner?', CAST(5.00 AS Decimal(18, 2)), 10)
INSERT [dbo].[RentableItems] ([ItemId], [TotalQuantity], [Name], [Description], [PricePerDay], [AvailableQuantity]) VALUES (10, 10, N'Kayak', N'Skilled enough to kayak in Neretva?', CAST(30.00 AS Decimal(18, 2)), 10)
INSERT [dbo].[RentableItems] ([ItemId], [TotalQuantity], [Name], [Description], [PricePerDay], [AvailableQuantity]) VALUES (11, 10, N'Chairs', N'Perfect chait to rest in nature', CAST(5.00 AS Decimal(18, 2)), 10)
INSERT [dbo].[RentableItems] ([ItemId], [TotalQuantity], [Name], [Description], [PricePerDay], [AvailableQuantity]) VALUES (12, 10, N'Coolers', N'Keep your food cool', CAST(5.00 AS Decimal(18, 2)), 10)
INSERT [dbo].[RentableItems] ([ItemId], [TotalQuantity], [Name], [Description], [PricePerDay], [AvailableQuantity]) VALUES (13, 10, N'Hammocks', N'Chill out and enjoy peace', CAST(5.00 AS Decimal(18, 2)), 10)
SET IDENTITY_INSERT [dbo].[RentableItems] OFF
GO
INSERT [dbo].[ReservationAccommodations] ([ReservationId], [AccommodationId], [Quantity]) VALUES (99, 2, 1)
INSERT [dbo].[ReservationAccommodations] ([ReservationId], [AccommodationId], [Quantity]) VALUES (100, 2, 1)
INSERT [dbo].[ReservationAccommodations] ([ReservationId], [AccommodationId], [Quantity]) VALUES (101, 5, 1)
INSERT [dbo].[ReservationAccommodations] ([ReservationId], [AccommodationId], [Quantity]) VALUES (102, 2, 1)
INSERT [dbo].[ReservationAccommodations] ([ReservationId], [AccommodationId], [Quantity]) VALUES (103, 1, 1)
INSERT [dbo].[ReservationAccommodations] ([ReservationId], [AccommodationId], [Quantity]) VALUES (104, 2, 1)
INSERT [dbo].[ReservationAccommodations] ([ReservationId], [AccommodationId], [Quantity]) VALUES (105, 2, 1)
INSERT [dbo].[ReservationAccommodations] ([ReservationId], [AccommodationId], [Quantity]) VALUES (106, 5, 1)
INSERT [dbo].[ReservationAccommodations] ([ReservationId], [AccommodationId], [Quantity]) VALUES (107, 2, 1)
INSERT [dbo].[ReservationAccommodations] ([ReservationId], [AccommodationId], [Quantity]) VALUES (108, 6, 1)
INSERT [dbo].[ReservationAccommodations] ([ReservationId], [AccommodationId], [Quantity]) VALUES (109, 2, 1)
INSERT [dbo].[ReservationAccommodations] ([ReservationId], [AccommodationId], [Quantity]) VALUES (110, 1, 1)
INSERT [dbo].[ReservationAccommodations] ([ReservationId], [AccommodationId], [Quantity]) VALUES (111, 2, 1)
INSERT [dbo].[ReservationAccommodations] ([ReservationId], [AccommodationId], [Quantity]) VALUES (112, 2, 1)
INSERT [dbo].[ReservationAccommodations] ([ReservationId], [AccommodationId], [Quantity]) VALUES (113, 2, 1)
INSERT [dbo].[ReservationAccommodations] ([ReservationId], [AccommodationId], [Quantity]) VALUES (114, 2, 1)
INSERT [dbo].[ReservationAccommodations] ([ReservationId], [AccommodationId], [Quantity]) VALUES (115, 2, 1)
INSERT [dbo].[ReservationAccommodations] ([ReservationId], [AccommodationId], [Quantity]) VALUES (116, 5, 1)
INSERT [dbo].[ReservationAccommodations] ([ReservationId], [AccommodationId], [Quantity]) VALUES (117, 2, 1)
INSERT [dbo].[ReservationAccommodations] ([ReservationId], [AccommodationId], [Quantity]) VALUES (121, 1, 1)
GO
INSERT [dbo].[ReservationActivities] ([ReservationId], [ActivityId]) VALUES (105, 13)
INSERT [dbo].[ReservationActivities] ([ReservationId], [ActivityId]) VALUES (106, 16)
INSERT [dbo].[ReservationActivities] ([ReservationId], [ActivityId]) VALUES (111, 18)
INSERT [dbo].[ReservationActivities] ([ReservationId], [ActivityId]) VALUES (112, 18)
INSERT [dbo].[ReservationActivities] ([ReservationId], [ActivityId]) VALUES (117, 18)
GO
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (99, 1, 2)
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (100, 1, 2)
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (101, 1, 2)
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (102, 1, 3)
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (103, 1, 2)
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (103, 2, 1)
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (104, 1, 3)
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (105, 1, 3)
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (106, 1, 3)
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (107, 1, 2)
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (107, 2, 1)
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (108, 1, 2)
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (110, 1, 2)
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (111, 1, 4)
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (111, 2, 1)
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (112, 1, 2)
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (113, 1, 2)
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (114, 1, 2)
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (115, 1, 2)
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (116, 1, 2)
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (117, 1, 2)
INSERT [dbo].[ReservationPersons] ([ReservationId], [PersonId], [Quantity]) VALUES (121, 1, 2)
GO
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (99, 1, 2)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (101, 7, 1)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (101, 8, 0)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (101, 12, 1)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (102, 1, 3)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (103, 2, 2)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (103, 9, 1)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (104, 8, 1)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (104, 10, 2)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (105, 1, 1)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (105, 13, 2)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (106, 1, 3)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (106, 2, 3)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (106, 12, 1)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (107, 1, 2)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (107, 9, 1)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (107, 10, 2)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (107, 11, 3)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (108, 12, 1)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (109, 10, 1)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (109, 11, 1)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (109, 12, 1)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (110, 2, 2)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (111, 7, 1)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (111, 9, 1)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (111, 11, 2)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (112, 13, 1)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (113, 10, 1)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (113, 12, 1)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (114, 9, 1)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (114, 11, 0)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (114, 12, 1)
INSERT [dbo].[ReservationRentables] ([ReservationId], [ItemId], [Quantity]) VALUES (116, 12, 1)
GO
SET IDENTITY_INSERT [dbo].[Reservations] ON 

INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (99, 40, 2, CAST(N'2025-06-20T00:00:00.000' AS DateTime), CAST(N'2025-06-21T00:00:00.000' AS DateTime), CAST(53.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (100, 40, 52, CAST(N'2025-06-20T00:00:00.000' AS DateTime), CAST(N'2025-06-21T00:00:00.000' AS DateTime), CAST(35.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (101, 41, 23, CAST(N'2025-06-17T00:00:00.000' AS DateTime), CAST(N'2025-06-18T00:00:00.000' AS DateTime), CAST(110.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (102, 41, 17, CAST(N'2025-06-19T00:00:00.000' AS DateTime), CAST(N'2025-06-20T00:00:00.000' AS DateTime), CAST(70.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (103, 41, 3, CAST(N'2025-06-25T00:00:00.000' AS DateTime), CAST(N'2025-06-26T00:00:00.000' AS DateTime), CAST(48.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (104, 42, 17, CAST(N'2025-06-27T00:00:00.000' AS DateTime), CAST(N'2025-06-28T00:00:00.000' AS DateTime), CAST(110.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (105, 42, 18, CAST(N'2025-06-15T00:00:00.000' AS DateTime), CAST(N'2025-06-16T00:00:00.000' AS DateTime), CAST(70.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (106, 42, 3, CAST(N'2025-06-17T00:00:00.000' AS DateTime), CAST(N'2025-06-20T00:00:00.000' AS DateTime), CAST(415.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (107, 43, 3, CAST(N'2025-06-27T00:00:00.000' AS DateTime), CAST(N'2025-06-28T00:00:00.000' AS DateTime), CAST(138.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (108, 43, 2, CAST(N'2025-06-29T00:00:00.000' AS DateTime), CAST(N'2025-06-30T00:00:00.000' AS DateTime), CAST(35.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (109, 44, 3, CAST(N'2025-06-20T00:00:00.000' AS DateTime), CAST(N'2025-06-21T00:00:00.000' AS DateTime), CAST(65.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (110, 44, 18, CAST(N'2025-06-19T00:00:00.000' AS DateTime), CAST(N'2025-06-20T00:00:00.000' AS DateTime), CAST(38.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (111, 45, 17, CAST(N'2025-06-25T00:00:00.000' AS DateTime), CAST(N'2025-06-26T00:00:00.000' AS DateTime), CAST(113.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (112, 46, 23, CAST(N'2025-06-25T00:00:00.000' AS DateTime), CAST(N'2025-06-26T00:00:00.000' AS DateTime), CAST(50.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (113, 47, 17, CAST(N'2025-06-18T00:00:00.000' AS DateTime), CAST(N'2025-06-19T00:00:00.000' AS DateTime), CAST(70.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (114, 47, 17, CAST(N'2025-07-01T00:00:00.000' AS DateTime), CAST(N'2025-07-02T00:00:00.000' AS DateTime), CAST(45.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (115, 40, 17, CAST(N'2025-06-20T00:00:00.000' AS DateTime), CAST(N'2025-06-21T00:00:00.000' AS DateTime), CAST(35.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (116, 43, 3, CAST(N'2025-06-26T00:00:00.000' AS DateTime), CAST(N'2025-06-27T00:00:00.000' AS DateTime), CAST(70.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (117, 43, 18, CAST(N'2025-06-25T00:00:00.000' AS DateTime), CAST(N'2025-06-26T00:00:00.000' AS DateTime), CAST(45.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (118, 43, 2, CAST(N'2025-06-23T00:00:00.000' AS DateTime), CAST(N'2025-06-24T00:00:00.000' AS DateTime), CAST(33.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (119, 43, 2, CAST(N'2025-06-17T00:00:00.000' AS DateTime), CAST(N'2025-06-18T00:00:00.000' AS DateTime), CAST(35.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (120, 43, 18, CAST(N'2025-06-17T00:00:00.000' AS DateTime), CAST(N'2025-06-18T00:00:00.000' AS DateTime), CAST(35.00 AS Decimal(18, 2)), N'Pending')
INSERT [dbo].[Reservations] ([ReservationId], [UserId], [ParcelId], [CheckInDate], [CheckOutDate], [TotalPrice], [PaymentStatus]) VALUES (121, 43, 3, CAST(N'2025-06-23T00:00:00.000' AS DateTime), CAST(N'2025-06-24T00:00:00.000' AS DateTime), CAST(20.00 AS Decimal(18, 2)), N'Pending')
SET IDENTITY_INSERT [dbo].[Reservations] OFF
GO
INSERT [dbo].[ReservationVehicles] ([ReservationId], [VehicleId], [Quantity]) VALUES (99, 2, 1)
INSERT [dbo].[ReservationVehicles] ([ReservationId], [VehicleId], [Quantity]) VALUES (100, 1, 1)
INSERT [dbo].[ReservationVehicles] ([ReservationId], [VehicleId], [Quantity]) VALUES (101, 1, 1)
INSERT [dbo].[ReservationVehicles] ([ReservationId], [VehicleId], [Quantity]) VALUES (102, 1, 1)
INSERT [dbo].[ReservationVehicles] ([ReservationId], [VehicleId], [Quantity]) VALUES (103, 1, 1)
INSERT [dbo].[ReservationVehicles] ([ReservationId], [VehicleId], [Quantity]) VALUES (104, 1, 1)
INSERT [dbo].[ReservationVehicles] ([ReservationId], [VehicleId], [Quantity]) VALUES (105, 1, 1)
INSERT [dbo].[ReservationVehicles] ([ReservationId], [VehicleId], [Quantity]) VALUES (106, 1, 1)
INSERT [dbo].[ReservationVehicles] ([ReservationId], [VehicleId], [Quantity]) VALUES (107, 1, 1)
INSERT [dbo].[ReservationVehicles] ([ReservationId], [VehicleId], [Quantity]) VALUES (108, 14, 1)
INSERT [dbo].[ReservationVehicles] ([ReservationId], [VehicleId], [Quantity]) VALUES (109, 1, 1)
INSERT [dbo].[ReservationVehicles] ([ReservationId], [VehicleId], [Quantity]) VALUES (110, 2, 1)
INSERT [dbo].[ReservationVehicles] ([ReservationId], [VehicleId], [Quantity]) VALUES (111, 1, 1)
INSERT [dbo].[ReservationVehicles] ([ReservationId], [VehicleId], [Quantity]) VALUES (112, 1, 1)
INSERT [dbo].[ReservationVehicles] ([ReservationId], [VehicleId], [Quantity]) VALUES (113, 1, 1)
INSERT [dbo].[ReservationVehicles] ([ReservationId], [VehicleId], [Quantity]) VALUES (114, 1, 1)
INSERT [dbo].[ReservationVehicles] ([ReservationId], [VehicleId], [Quantity]) VALUES (115, 1, 1)
INSERT [dbo].[ReservationVehicles] ([ReservationId], [VehicleId], [Quantity]) VALUES (116, 1, 1)
INSERT [dbo].[ReservationVehicles] ([ReservationId], [VehicleId], [Quantity]) VALUES (117, 1, 1)
INSERT [dbo].[ReservationVehicles] ([ReservationId], [VehicleId], [Quantity]) VALUES (121, 1, 1)
GO
SET IDENTITY_INSERT [dbo].[Reviews] ON 

INSERT [dbo].[Reviews] ([ReviewId], [UserId], [WorkerId], [Rating], [Comment], [DatePosted]) VALUES (22, 40, 1, 5, N'helpful guy', CAST(N'2025-06-14T21:41:08.367' AS DateTime))
INSERT [dbo].[Reviews] ([ReviewId], [UserId], [WorkerId], [Rating], [Comment], [DatePosted]) VALUES (23, 42, 7, 4, N'polite but bit lazy', CAST(N'2025-06-14T21:43:10.227' AS DateTime))
INSERT [dbo].[Reviews] ([ReviewId], [UserId], [WorkerId], [Rating], [Comment], [DatePosted]) VALUES (24, 42, 3, 5, N'helped with taxi', CAST(N'2025-06-14T21:43:33.997' AS DateTime))
SET IDENTITY_INSERT [dbo].[Reviews] OFF
GO
SET IDENTITY_INSERT [dbo].[Roles] ON 

INSERT [dbo].[Roles] ([RoleId], [RoleName]) VALUES (1, N'Barista')
INSERT [dbo].[Roles] ([RoleId], [RoleName]) VALUES (2, N'Receptionist')
INSERT [dbo].[Roles] ([RoleId], [RoleName]) VALUES (3, N'Kayaker')
INSERT [dbo].[Roles] ([RoleId], [RoleName]) VALUES (4, N'Griller')
INSERT [dbo].[Roles] ([RoleId], [RoleName]) VALUES (17, N'Cleaner')
SET IDENTITY_INSERT [dbo].[Roles] OFF
GO
SET IDENTITY_INSERT [dbo].[UserPreference] ON 

INSERT [dbo].[UserPreference] ([UserPreferenceId], [UserId], [NumberOfPeople], [HasSmallChildren], [HasSeniorTravelers], [CarLength], [HasDogs]) VALUES (21, 40, 2, 0, 0, N'Small', 0)
INSERT [dbo].[UserPreference] ([UserPreferenceId], [UserId], [NumberOfPeople], [HasSmallChildren], [HasSeniorTravelers], [CarLength], [HasDogs]) VALUES (22, 41, 2, 1, 0, N'Small', 1)
INSERT [dbo].[UserPreference] ([UserPreferenceId], [UserId], [NumberOfPeople], [HasSmallChildren], [HasSeniorTravelers], [CarLength], [HasDogs]) VALUES (23, 42, 3, 1, 0, N'Large', 1)
INSERT [dbo].[UserPreference] ([UserPreferenceId], [UserId], [NumberOfPeople], [HasSmallChildren], [HasSeniorTravelers], [CarLength], [HasDogs]) VALUES (24, 43, 3, 1, 0, N'Large', 1)
INSERT [dbo].[UserPreference] ([UserPreferenceId], [UserId], [NumberOfPeople], [HasSmallChildren], [HasSeniorTravelers], [CarLength], [HasDogs]) VALUES (25, 44, 5, 0, 1, N'Small', 1)
INSERT [dbo].[UserPreference] ([UserPreferenceId], [UserId], [NumberOfPeople], [HasSmallChildren], [HasSeniorTravelers], [CarLength], [HasDogs]) VALUES (26, 45, 5, 1, 1, N'Large', 0)
INSERT [dbo].[UserPreference] ([UserPreferenceId], [UserId], [NumberOfPeople], [HasSmallChildren], [HasSeniorTravelers], [CarLength], [HasDogs]) VALUES (27, 46, 2, 1, 1, N'Small', 1)
INSERT [dbo].[UserPreference] ([UserPreferenceId], [UserId], [NumberOfPeople], [HasSmallChildren], [HasSeniorTravelers], [CarLength], [HasDogs]) VALUES (28, 47, 2, 0, 0, N'Small', 0)
SET IDENTITY_INSERT [dbo].[UserPreference] OFF
GO
SET IDENTITY_INSERT [dbo].[UserRecommendations] ON 

INSERT [dbo].[UserRecommendations] ([Id], [UserId], [ParcelId1], [ParcelId2], [ParcelId3], [ActivityId1], [ActivityId2], [RentableItemId1], [RentableItemId2]) VALUES (640, 40, 17, 0, 0, 0, 0, 9, 10)
INSERT [dbo].[UserRecommendations] ([Id], [UserId], [ParcelId1], [ParcelId2], [ParcelId3], [ActivityId1], [ActivityId2], [RentableItemId1], [RentableItemId2]) VALUES (641, 41, 23, 0, 0, 18, 0, 13, 0)
INSERT [dbo].[UserRecommendations] ([Id], [UserId], [ParcelId1], [ParcelId2], [ParcelId3], [ActivityId1], [ActivityId2], [RentableItemId1], [RentableItemId2]) VALUES (642, 42, 2, 3, 18, 18, 0, 1, 9)
INSERT [dbo].[UserRecommendations] ([Id], [UserId], [ParcelId1], [ParcelId2], [ParcelId3], [ActivityId1], [ActivityId2], [RentableItemId1], [RentableItemId2]) VALUES (643, 43, 3, 17, 18, 13, 16, 1, 2)
INSERT [dbo].[UserRecommendations] ([Id], [UserId], [ParcelId1], [ParcelId2], [ParcelId3], [ActivityId1], [ActivityId2], [RentableItemId1], [RentableItemId2]) VALUES (644, 46, 3, 17, 23, 0, 0, 1, 2)
INSERT [dbo].[UserRecommendations] ([Id], [UserId], [ParcelId1], [ParcelId2], [ParcelId3], [ActivityId1], [ActivityId2], [RentableItemId1], [RentableItemId2]) VALUES (645, 47, 2, 17, 52, 0, 0, 1, 0)
SET IDENTITY_INSERT [dbo].[UserRecommendations] OFF
GO
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Email], [PasswordHash], [PhoneNumber], [PasswordSalt], [UserName], [UserTypeId]) VALUES (39, N'Admin', N'Admin', N'redzepcamping@gmail.com', N'YkS+nsHi//lqM0Chp46AKx7qII0=', NULL, N'vf8ULMnTcLY3JqS/0ktWRg==', N'admin', 2)
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Email], [PasswordHash], [PhoneNumber], [PasswordSalt], [UserName], [UserTypeId]) VALUES (40, N'Guest', N'Guest', N'redzoguest+1@gmail.com', N'8necFAP+vbJ+AwXLBhmyOgVYdrY=', N'062233333', N'FNIgN0cU6XWshU9f6zNp1A==', N'guest1', 1)
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Email], [PasswordHash], [PhoneNumber], [PasswordSalt], [UserName], [UserTypeId]) VALUES (41, N'Customer', N'Customer', N'redzoguest+2@gmail.com', N'W41B4D4e/eGqNb44tI9iJqj7eoQ=', N'061234567', N'42L4srGXuSNbC/mO2o+o3A==', N'guest2', 1)
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Email], [PasswordHash], [PhoneNumber], [PasswordSalt], [UserName], [UserTypeId]) VALUES (42, N'Gost', N'Gost', N'redzoguest+3@gmail.com', N'fBmii7UClLqvG9mJC8ywxOD2jA0=', N'0633457889', N'MxaRl0yD+RQbIHpgDHsw+A==', N'guest3', 1)
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Email], [PasswordHash], [PhoneNumber], [PasswordSalt], [UserName], [UserTypeId]) VALUES (43, N'Kamper', N'Kamper', N'redzoguest+4@gmail.com', N'xF9j1uv5VvmH9iNv6vyLnCojFhs=', N'060999999', N'DWhvZKdMiQvCyjhaaEDBwA==', N'guest4', 1)
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Email], [PasswordHash], [PhoneNumber], [PasswordSalt], [UserName], [UserTypeId]) VALUES (44, N'Camp', N'Camp', N'redzoguest+5@gmail.com', N'kIYYRKnBHz5dMDog/lwGowOVidI=', N'05432356', N'wRp+Fd7wYQ8FxT/jekRkVw==', N'guest5', 1)
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Email], [PasswordHash], [PhoneNumber], [PasswordSalt], [UserName], [UserTypeId]) VALUES (45, N'Camping', N'Camping', N'redzoguest+6@gmail.com', N'BtLBBZ1fyj3ub0RsJft5SpAc6KQ=', N'066543355', N'FKh+sELFhT9uojZB62BR/w==', N'guest6', 1)
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Email], [PasswordHash], [PhoneNumber], [PasswordSalt], [UserName], [UserTypeId]) VALUES (46, N'Neretva', N'Neretva', N'redzoguest+7@gmail.com', N'6PbkMMPq7gzkkRLKTsc1UhA0uSY=', N'66666666', N'tIUWkZ27AOaeU6PiFlGj1A==', N'guest7', 1)
INSERT [dbo].[Users] ([UserId], [FirstName], [LastName], [Email], [PasswordHash], [PhoneNumber], [PasswordSalt], [UserName], [UserTypeId]) VALUES (47, N'Biker', N'Motobiker', N'redzoguest+8@gmail.com', N'M22ZrneDv64hwKkYbPfVNMoje7M=', N'062357135', N'4zCA0PCvqvemeuI7QY0cTA==', N'guest8', 1)
SET IDENTITY_INSERT [dbo].[Users] OFF
GO
SET IDENTITY_INSERT [dbo].[UserType] ON 

INSERT [dbo].[UserType] ([UserTypeId], [TypeName]) VALUES (1, N'Guest')
INSERT [dbo].[UserType] ([UserTypeId], [TypeName]) VALUES (2, N'Admin')
SET IDENTITY_INSERT [dbo].[UserType] OFF
GO
SET IDENTITY_INSERT [dbo].[VehicleImages] ON 

INSERT [dbo].[VehicleImages] ([VehicleImageId], [VehicleId], [ImageId]) VALUES (96, 1, 194)
INSERT [dbo].[VehicleImages] ([VehicleImageId], [VehicleId], [ImageId]) VALUES (97, 2, 194)
INSERT [dbo].[VehicleImages] ([VehicleImageId], [VehicleId], [ImageId]) VALUES (98, 4, 194)
INSERT [dbo].[VehicleImages] ([VehicleImageId], [VehicleId], [ImageId]) VALUES (99, 14, 194)
SET IDENTITY_INSERT [dbo].[VehicleImages] OFF
GO
SET IDENTITY_INSERT [dbo].[Vehicles] ON 

INSERT [dbo].[Vehicles] ([VehicleId], [Type], [PricePerNight]) VALUES (1, N'car', CAST(5.00 AS Decimal(18, 2)))
INSERT [dbo].[Vehicles] ([VehicleId], [Type], [PricePerNight]) VALUES (2, N'motorbike', CAST(3.00 AS Decimal(18, 2)))
INSERT [dbo].[Vehicles] ([VehicleId], [Type], [PricePerNight]) VALUES (4, N'rooftents', CAST(10.00 AS Decimal(18, 2)))
INSERT [dbo].[Vehicles] ([VehicleId], [Type], [PricePerNight]) VALUES (14, N'Motohome', CAST(20.00 AS Decimal(18, 2)))
SET IDENTITY_INSERT [dbo].[Vehicles] OFF
GO
INSERT [dbo].[WorkerRoles] ([WorkerId], [RoleId]) VALUES (1, 1)
INSERT [dbo].[WorkerRoles] ([WorkerId], [RoleId]) VALUES (3, 1)
INSERT [dbo].[WorkerRoles] ([WorkerId], [RoleId]) VALUES (1, 2)
INSERT [dbo].[WorkerRoles] ([WorkerId], [RoleId]) VALUES (7, 2)
INSERT [dbo].[WorkerRoles] ([WorkerId], [RoleId]) VALUES (1, 4)
INSERT [dbo].[WorkerRoles] ([WorkerId], [RoleId]) VALUES (3, 4)
GO
SET IDENTITY_INSERT [dbo].[Workers] ON 

INSERT [dbo].[Workers] ([WorkerId], [FirstName], [LastName], [PhoneNumber], [Email]) VALUES (1, N'Redzep', N'Trebovic', N'061020403', N'redzo@gmail.com')
INSERT [dbo].[Workers] ([WorkerId], [FirstName], [LastName], [PhoneNumber], [Email]) VALUES (3, N'Adnan', N'Kustric', N'06023473627', N'kustra@gmail.com')
INSERT [dbo].[Workers] ([WorkerId], [FirstName], [LastName], [PhoneNumber], [Email]) VALUES (7, N'Ibrahim', N'Topic', N'052243412', N'ibro@gmail.com')
SET IDENTITY_INSERT [dbo].[Workers] OFF
GO
/****** Object:  Index [IX_Users_UserTypeId]    Script Date: 6/15/2025 4:38:24 PM ******/
CREATE NONCLUSTERED INDEX [IX_Users_UserTypeId] ON [dbo].[Users]
(
	[UserTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_WorkerRoles_RoleId]    Script Date: 6/15/2025 4:38:24 PM ******/
CREATE NONCLUSTERED INDEX [IX_WorkerRoles_RoleId] ON [dbo].[WorkerRoles]
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Images] ADD  DEFAULT (getdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[Payments] ADD  DEFAULT ('PENDING') FOR [Status]
GO
ALTER TABLE [dbo].[UserPreference] ADD  DEFAULT ((0)) FOR [HasSmallChildren]
GO
ALTER TABLE [dbo].[UserPreference] ADD  DEFAULT ((0)) FOR [HasSeniorTravelers]
GO
ALTER TABLE [dbo].[UserPreference] ADD  DEFAULT ((0)) FOR [HasDogs]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF__Users__UserTypeI__2180FB33]  DEFAULT ((0)) FOR [UserTypeId]
GO
ALTER TABLE [dbo].[AccommodationImages]  WITH CHECK ADD  CONSTRAINT [FK_AccommodationImages_Accommodations] FOREIGN KEY([AccommodationId])
REFERENCES [dbo].[Accommodations] ([AccommodationId])
GO
ALTER TABLE [dbo].[AccommodationImages] CHECK CONSTRAINT [FK_AccommodationImages_Accommodations]
GO
ALTER TABLE [dbo].[AccommodationImages]  WITH CHECK ADD  CONSTRAINT [FK_AccommodationImages_Images] FOREIGN KEY([ImageId])
REFERENCES [dbo].[Images] ([ImageId])
GO
ALTER TABLE [dbo].[AccommodationImages] CHECK CONSTRAINT [FK_AccommodationImages_Images]
GO
ALTER TABLE [dbo].[Activities]  WITH CHECK ADD  CONSTRAINT [FK__Activitie__Facil__6FE99F9F] FOREIGN KEY([FacilityId])
REFERENCES [dbo].[Facilities] ([FacilityId])
GO
ALTER TABLE [dbo].[Activities] CHECK CONSTRAINT [FK__Activitie__Facil__6FE99F9F]
GO
ALTER TABLE [dbo].[ActivityImages]  WITH CHECK ADD  CONSTRAINT [FK_ActivityImages_Images] FOREIGN KEY([ImageId])
REFERENCES [dbo].[Images] ([ImageId])
GO
ALTER TABLE [dbo].[ActivityImages] CHECK CONSTRAINT [FK_ActivityImages_Images]
GO
ALTER TABLE [dbo].[ActivityImages]  WITH CHECK ADD  CONSTRAINT [FK_ActivityImages_Vehicles] FOREIGN KEY([ActivityId])
REFERENCES [dbo].[Activities] ([ActivityId])
GO
ALTER TABLE [dbo].[ActivityImages] CHECK CONSTRAINT [FK_ActivityImages_Vehicles]
GO
ALTER TABLE [dbo].[ActivityWorkers]  WITH CHECK ADD  CONSTRAINT [FK__ActivityW__Activ__72C60C4A] FOREIGN KEY([ActivityId])
REFERENCES [dbo].[Activities] ([ActivityId])
GO
ALTER TABLE [dbo].[ActivityWorkers] CHECK CONSTRAINT [FK__ActivityW__Activ__72C60C4A]
GO
ALTER TABLE [dbo].[ActivityWorkers]  WITH CHECK ADD  CONSTRAINT [FK__ActivityW__Worke__73BA3083] FOREIGN KEY([WorkerId])
REFERENCES [dbo].[Workers] ([WorkerId])
GO
ALTER TABLE [dbo].[ActivityWorkers] CHECK CONSTRAINT [FK__ActivityW__Worke__73BA3083]
GO
ALTER TABLE [dbo].[FacilityImages]  WITH CHECK ADD  CONSTRAINT [FK_FacilityImages_Facilities] FOREIGN KEY([FacilityId])
REFERENCES [dbo].[Facilities] ([FacilityId])
GO
ALTER TABLE [dbo].[FacilityImages] CHECK CONSTRAINT [FK_FacilityImages_Facilities]
GO
ALTER TABLE [dbo].[FacilityImages]  WITH CHECK ADD  CONSTRAINT [FK_FacilityImages_Images] FOREIGN KEY([ImageId])
REFERENCES [dbo].[Images] ([ImageId])
GO
ALTER TABLE [dbo].[FacilityImages] CHECK CONSTRAINT [FK_FacilityImages_Images]
GO
ALTER TABLE [dbo].[ParcelImages]  WITH CHECK ADD  CONSTRAINT [FK_ParcelImage_Image] FOREIGN KEY([ImageId])
REFERENCES [dbo].[Images] ([ImageId])
GO
ALTER TABLE [dbo].[ParcelImages] CHECK CONSTRAINT [FK_ParcelImage_Image]
GO
ALTER TABLE [dbo].[ParcelImages]  WITH CHECK ADD  CONSTRAINT [FK_ParcelImage_Parcel] FOREIGN KEY([ParcelId])
REFERENCES [dbo].[Parcels] ([ParcelId])
GO
ALTER TABLE [dbo].[ParcelImages] CHECK CONSTRAINT [FK_ParcelImage_Parcel]
GO
ALTER TABLE [dbo].[Parcels]  WITH CHECK ADD FOREIGN KEY([ParcelAccommodationId])
REFERENCES [dbo].[ParcelAccommodations] ([ParcelAccommodationId])
GO
ALTER TABLE [dbo].[Parcels]  WITH CHECK ADD FOREIGN KEY([ParcelAccommodationId])
REFERENCES [dbo].[ParcelAccommodations] ([ParcelAccommodationId])
GO
ALTER TABLE [dbo].[Parcels]  WITH CHECK ADD FOREIGN KEY([ParcelTypeId])
REFERENCES [dbo].[ParcelTypes] ([ParcelTypeId])
GO
ALTER TABLE [dbo].[Parcels]  WITH CHECK ADD FOREIGN KEY([ParcelTypeId])
REFERENCES [dbo].[ParcelTypes] ([ParcelTypeId])
GO
ALTER TABLE [dbo].[Payments]  WITH CHECK ADD  CONSTRAINT [FK__Payments__Reserv__5070F446] FOREIGN KEY([ReservationId])
REFERENCES [dbo].[Reservations] ([ReservationId])
GO
ALTER TABLE [dbo].[Payments] CHECK CONSTRAINT [FK__Payments__Reserv__5070F446]
GO
ALTER TABLE [dbo].[Payments]  WITH CHECK ADD  CONSTRAINT [FK__Payments__UserId__5165187F] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Payments] CHECK CONSTRAINT [FK__Payments__UserId__5165187F]
GO
ALTER TABLE [dbo].[PersonImages]  WITH CHECK ADD  CONSTRAINT [FK_PersonImages_Images] FOREIGN KEY([ImageId])
REFERENCES [dbo].[Images] ([ImageId])
GO
ALTER TABLE [dbo].[PersonImages] CHECK CONSTRAINT [FK_PersonImages_Images]
GO
ALTER TABLE [dbo].[PersonImages]  WITH CHECK ADD  CONSTRAINT [FK_PersonImages_Persons] FOREIGN KEY([PersonId])
REFERENCES [dbo].[Persons] ([PersonId])
GO
ALTER TABLE [dbo].[PersonImages] CHECK CONSTRAINT [FK_PersonImages_Persons]
GO
ALTER TABLE [dbo].[RentableItemImages]  WITH CHECK ADD  CONSTRAINT [FK_RentableItemImages_Images] FOREIGN KEY([ImageId])
REFERENCES [dbo].[Images] ([ImageId])
GO
ALTER TABLE [dbo].[RentableItemImages] CHECK CONSTRAINT [FK_RentableItemImages_Images]
GO
ALTER TABLE [dbo].[RentableItemImages]  WITH CHECK ADD  CONSTRAINT [FK_RentableItemImages_RentableItems] FOREIGN KEY([RentableItemId])
REFERENCES [dbo].[RentableItems] ([ItemId])
GO
ALTER TABLE [dbo].[RentableItemImages] CHECK CONSTRAINT [FK_RentableItemImages_RentableItems]
GO
ALTER TABLE [dbo].[ReservationAccommodations]  WITH CHECK ADD  CONSTRAINT [FK__Reservati__Accom__628FA481] FOREIGN KEY([AccommodationId])
REFERENCES [dbo].[Accommodations] ([AccommodationId])
GO
ALTER TABLE [dbo].[ReservationAccommodations] CHECK CONSTRAINT [FK__Reservati__Accom__628FA481]
GO
ALTER TABLE [dbo].[ReservationAccommodations]  WITH CHECK ADD  CONSTRAINT [FK__Reservati__Reser__619B8048] FOREIGN KEY([ReservationId])
REFERENCES [dbo].[Reservations] ([ReservationId])
GO
ALTER TABLE [dbo].[ReservationAccommodations] CHECK CONSTRAINT [FK__Reservati__Reser__619B8048]
GO
ALTER TABLE [dbo].[ReservationActivities]  WITH CHECK ADD  CONSTRAINT [FK__Reservati__Activ__440B1D61] FOREIGN KEY([ActivityId])
REFERENCES [dbo].[Activities] ([ActivityId])
GO
ALTER TABLE [dbo].[ReservationActivities] CHECK CONSTRAINT [FK__Reservati__Activ__440B1D61]
GO
ALTER TABLE [dbo].[ReservationActivities]  WITH CHECK ADD  CONSTRAINT [FK__Reservati__Reser__4316F928] FOREIGN KEY([ReservationId])
REFERENCES [dbo].[Reservations] ([ReservationId])
GO
ALTER TABLE [dbo].[ReservationActivities] CHECK CONSTRAINT [FK__Reservati__Reser__4316F928]
GO
ALTER TABLE [dbo].[ReservationPersons]  WITH CHECK ADD  CONSTRAINT [FK__Reservati__Perso__5AEE82B9] FOREIGN KEY([PersonId])
REFERENCES [dbo].[Persons] ([PersonId])
GO
ALTER TABLE [dbo].[ReservationPersons] CHECK CONSTRAINT [FK__Reservati__Perso__5AEE82B9]
GO
ALTER TABLE [dbo].[ReservationPersons]  WITH CHECK ADD  CONSTRAINT [FK__Reservati__Reser__59FA5E80] FOREIGN KEY([ReservationId])
REFERENCES [dbo].[Reservations] ([ReservationId])
GO
ALTER TABLE [dbo].[ReservationPersons] CHECK CONSTRAINT [FK__Reservati__Reser__59FA5E80]
GO
ALTER TABLE [dbo].[ReservationRentables]  WITH CHECK ADD  CONSTRAINT [FK__Reservati__ItemI__47DBAE45] FOREIGN KEY([ItemId])
REFERENCES [dbo].[RentableItems] ([ItemId])
GO
ALTER TABLE [dbo].[ReservationRentables] CHECK CONSTRAINT [FK__Reservati__ItemI__47DBAE45]
GO
ALTER TABLE [dbo].[ReservationRentables]  WITH CHECK ADD  CONSTRAINT [FK__Reservati__Reser__46E78A0C] FOREIGN KEY([ReservationId])
REFERENCES [dbo].[Reservations] ([ReservationId])
GO
ALTER TABLE [dbo].[ReservationRentables] CHECK CONSTRAINT [FK__Reservati__Reser__46E78A0C]
GO
ALTER TABLE [dbo].[Reservations]  WITH CHECK ADD  CONSTRAINT [FK__Reservati__Parce__3C69FB99] FOREIGN KEY([ParcelId])
REFERENCES [dbo].[Parcels] ([ParcelId])
GO
ALTER TABLE [dbo].[Reservations] CHECK CONSTRAINT [FK__Reservati__Parce__3C69FB99]
GO
ALTER TABLE [dbo].[Reservations]  WITH CHECK ADD  CONSTRAINT [FK__Reservati__UserI__3B75D760] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Reservations] CHECK CONSTRAINT [FK__Reservati__UserI__3B75D760]
GO
ALTER TABLE [dbo].[ReservationVehicles]  WITH CHECK ADD  CONSTRAINT [FK__Reservati__Reser__5DCAEF64] FOREIGN KEY([ReservationId])
REFERENCES [dbo].[Reservations] ([ReservationId])
GO
ALTER TABLE [dbo].[ReservationVehicles] CHECK CONSTRAINT [FK__Reservati__Reser__5DCAEF64]
GO
ALTER TABLE [dbo].[ReservationVehicles]  WITH CHECK ADD  CONSTRAINT [FK__Reservati__Vehic__5EBF139D] FOREIGN KEY([VehicleId])
REFERENCES [dbo].[Vehicles] ([VehicleId])
GO
ALTER TABLE [dbo].[ReservationVehicles] CHECK CONSTRAINT [FK__Reservati__Vehic__5EBF139D]
GO
ALTER TABLE [dbo].[Reviews]  WITH CHECK ADD  CONSTRAINT [FK__Reviews__UserId__4AB81AF0] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Reviews] CHECK CONSTRAINT [FK__Reviews__UserId__4AB81AF0]
GO
ALTER TABLE [dbo].[Reviews]  WITH CHECK ADD  CONSTRAINT [FK__Reviews__WorkerI__4D94879B] FOREIGN KEY([WorkerId])
REFERENCES [dbo].[Workers] ([WorkerId])
GO
ALTER TABLE [dbo].[Reviews] CHECK CONSTRAINT [FK__Reviews__WorkerI__4D94879B]
GO
ALTER TABLE [dbo].[UserPreference]  WITH CHECK ADD  CONSTRAINT [FK_UserPreference_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[UserPreference] CHECK CONSTRAINT [FK_UserPreference_User]
GO
ALTER TABLE [dbo].[UserRecommendations]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[UserRecommendations]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK__Users__UserTypeI__ABCDEF12] FOREIGN KEY([UserTypeId])
REFERENCES [dbo].[UserType] ([UserTypeId])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK__Users__UserTypeI__ABCDEF12]
GO
ALTER TABLE [dbo].[VehicleImages]  WITH CHECK ADD  CONSTRAINT [FK_VehicleImages_Images] FOREIGN KEY([ImageId])
REFERENCES [dbo].[Images] ([ImageId])
GO
ALTER TABLE [dbo].[VehicleImages] CHECK CONSTRAINT [FK_VehicleImages_Images]
GO
ALTER TABLE [dbo].[VehicleImages]  WITH CHECK ADD  CONSTRAINT [FK_VehicleImages_Vehicles] FOREIGN KEY([VehicleId])
REFERENCES [dbo].[Vehicles] ([VehicleId])
GO
ALTER TABLE [dbo].[VehicleImages] CHECK CONSTRAINT [FK_VehicleImages_Vehicles]
GO
ALTER TABLE [dbo].[WorkerRoles]  WITH CHECK ADD  CONSTRAINT [FK__WorkerRol__RoleI__76543210] FOREIGN KEY([RoleId])
REFERENCES [dbo].[Roles] ([RoleId])
GO
ALTER TABLE [dbo].[WorkerRoles] CHECK CONSTRAINT [FK__WorkerRol__RoleI__76543210]
GO
ALTER TABLE [dbo].[WorkerRoles]  WITH CHECK ADD  CONSTRAINT [FK__WorkerRol__Worke__01234567] FOREIGN KEY([WorkerId])
REFERENCES [dbo].[Workers] ([WorkerId])
GO
ALTER TABLE [dbo].[WorkerRoles] CHECK CONSTRAINT [FK__WorkerRol__Worke__01234567]
GO
ALTER TABLE [dbo].[UserPreference]  WITH CHECK ADD CHECK  (([CarLength]='Large' OR [CarLength]='Medium' OR [CarLength]='Small'))
GO
ALTER TABLE [dbo].[UserPreference]  WITH CHECK ADD CHECK  (([CarLength]='Large' OR [CarLength]='Medium' OR [CarLength]='Small'))
GO
USE [master]
GO
ALTER DATABASE [200012] SET  READ_WRITE 
GO
