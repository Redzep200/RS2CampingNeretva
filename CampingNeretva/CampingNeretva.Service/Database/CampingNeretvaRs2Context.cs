using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace CampingNeretva.Service.Database;

public partial class CampingNeretvaRs2Context : DbContext
{
    public CampingNeretvaRs2Context()
    {
    }

    public CampingNeretvaRs2Context(DbContextOptions<CampingNeretvaRs2Context> options)
        : base(options)
    {
    }

    public virtual DbSet<Accommodation> Accommodations { get; set; }

    public virtual DbSet<Activity> Activities { get; set; }

    public virtual DbSet<Facility> Facilities { get; set; }

    public virtual DbSet<Parcel> Parcels { get; set; }

    public virtual DbSet<Payment> Payments { get; set; }

    public virtual DbSet<Person> Persons { get; set; }

    public virtual DbSet<RentableItem> RentableItems { get; set; }

    public virtual DbSet<Reservation> Reservations { get; set; }

    public virtual DbSet<ReservationAccommodation> ReservationAccommodations { get; set; }

    public virtual DbSet<ReservationPerson> ReservationPersons { get; set; }

    public virtual DbSet<ReservationRentable> ReservationRentables { get; set; }

    public virtual DbSet<ReservationVehicle> ReservationVehicles { get; set; }

    public virtual DbSet<Review> Reviews { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<User> Users { get; set; }

    public virtual DbSet<UserType> UserTypes { get; set; }

    public virtual DbSet<Vehicle> Vehicles { get; set; }

    public virtual DbSet<Worker> Workers { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Data Source=DESKTOP-1MUH4I3;Initial Catalog=CampingNeretva_RS2;Integrated Security=True;TrustServerCertificate=True");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Accommodation>(entity =>
        {
            entity.HasKey(e => e.AccommodationId).HasName("PK__Accommod__DBB30A518EBF438C");

            entity.Property(e => e.PricePerNight).HasColumnType("decimal(18, 2)");
        });

        modelBuilder.Entity<Activity>(entity =>
        {
            entity.HasKey(e => e.ActivityId).HasName("PK__Activiti__45F4A791551271B0");

            entity.Property(e => e.Date).HasColumnType("datetime");
            entity.Property(e => e.Price).HasColumnType("decimal(18, 2)");

            entity.HasOne(d => d.Facility).WithMany(p => p.Activities)
                .HasForeignKey(d => d.FacilityId)
                .HasConstraintName("FK__Activitie__Facil__6FE99F9F");

            entity.HasMany(d => d.Workers).WithMany(p => p.Activities)
                .UsingEntity<Dictionary<string, object>>(
                    "ActivityWorker",
                    r => r.HasOne<Worker>().WithMany()
                        .HasForeignKey("WorkerId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK__ActivityW__Worke__73BA3083"),
                    l => l.HasOne<Activity>().WithMany()
                        .HasForeignKey("ActivityId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK__ActivityW__Activ__72C60C4A"),
                    j =>
                    {
                        j.HasKey("ActivityId", "WorkerId").HasName("PK__Activity__35836F130254DC34");
                        j.ToTable("ActivityWorkers");
                    });
        });

        modelBuilder.Entity<Facility>(entity =>
        {
            entity.HasKey(e => e.FacilityId).HasName("PK__Faciliti__5FB08A74FF9A6D7B");
        });

        modelBuilder.Entity<Parcel>(entity =>
        {
            entity.HasKey(e => e.ParcelId).HasName("PK__Parcels__B5F2167B0DA861B2");
        });

        modelBuilder.Entity<Payment>(entity =>
        {
            entity.HasKey(e => e.PaymentId).HasName("PK__Payments__9B556A3894676AAF");

            entity.Property(e => e.Amount).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.TransactionDate).HasColumnType("datetime");

            entity.HasOne(d => d.Reservation).WithMany(p => p.Payments)
                .HasForeignKey(d => d.ReservationId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Payments__Reserv__5070F446");

            entity.HasOne(d => d.User).WithMany(p => p.Payments)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Payments__UserId__5165187F");
        });

        modelBuilder.Entity<Person>(entity =>
        {
            entity.HasKey(e => e.PersonId).HasName("PK__Persons__AA2FFBE58994B53E");

            entity.Property(e => e.PricePerNight).HasColumnType("decimal(18, 2)");
        });

        modelBuilder.Entity<RentableItem>(entity =>
        {
            entity.HasKey(e => e.ItemId).HasName("PK__Rentable__727E838B778586B3");

            entity.Property(e => e.PricePerDay).HasColumnType("decimal(18, 2)");
        });

        modelBuilder.Entity<Reservation>(entity =>
        {
            entity.HasKey(e => e.ReservationId).HasName("PK__Reservat__B7EE5F243AA4F869");

            entity.Property(e => e.CheckInDate).HasColumnType("datetime");
            entity.Property(e => e.CheckOutDate).HasColumnType("datetime");
            entity.Property(e => e.TotalPrice).HasColumnType("decimal(18, 2)");

            entity.HasOne(d => d.Parcel).WithMany(p => p.Reservations)
                .HasForeignKey(d => d.ParcelId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Reservati__Parce__3C69FB99");

            entity.HasOne(d => d.User).WithMany(p => p.Reservations)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Reservati__UserI__3B75D760");

            entity.HasMany(d => d.Activities).WithMany(p => p.Reservations)
                .UsingEntity<Dictionary<string, object>>(
                    "ReservationActivity",
                    r => r.HasOne<Activity>().WithMany()
                        .HasForeignKey("ActivityId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK__Reservati__Activ__440B1D61"),
                    l => l.HasOne<Reservation>().WithMany()
                        .HasForeignKey("ReservationId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK__Reservati__Reser__4316F928"),
                    j =>
                    {
                        j.HasKey("ReservationId", "ActivityId").HasName("PK__Reservat__B3B1155DA7C583C9");
                        j.ToTable("ReservationActivities");
                    });
        });

        modelBuilder.Entity<ReservationAccommodation>(entity =>
        {
            entity.HasKey(e => new { e.ReservationId, e.AccommodationId }).HasName("PK__Reservat__BA556F81D6DFD313");

            entity.HasOne(d => d.Accommodation).WithMany(p => p.ReservationAccommodations)
                .HasForeignKey(d => d.AccommodationId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Reservati__Accom__628FA481");

            entity.HasOne(d => d.Reservation).WithMany(p => p.ReservationAccommodations)
                .HasForeignKey(d => d.ReservationId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Reservati__Reser__619B8048");
        });

        modelBuilder.Entity<ReservationPerson>(entity =>
        {
            entity.HasKey(e => new { e.ReservationId, e.PersonId }).HasName("PK__Reservat__FD4CA09AC6619247");

            entity.HasOne(d => d.Person).WithMany(p => p.ReservationPeople)
                .HasForeignKey(d => d.PersonId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Reservati__Perso__5AEE82B9");

            entity.HasOne(d => d.Reservation).WithMany(p => p.ReservationPeople)
                .HasForeignKey(d => d.ReservationId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Reservati__Reser__59FA5E80");
        });

        modelBuilder.Entity<ReservationRentable>(entity =>
        {
            entity.HasKey(e => new { e.ReservationId, e.ItemId }).HasName("PK__Reservat__10C9B71CA8B98473");

            entity.HasOne(d => d.Item).WithMany(p => p.ReservationRentables)
                .HasForeignKey(d => d.ItemId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Reservati__ItemI__47DBAE45");

            entity.HasOne(d => d.Reservation).WithMany(p => p.ReservationRentables)
                .HasForeignKey(d => d.ReservationId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Reservati__Reser__46E78A0C");
        });

        modelBuilder.Entity<ReservationVehicle>(entity =>
        {
            entity.HasKey(e => new { e.ReservationId, e.VehicleId }).HasName("PK__Reservat__8398EA6D3FB216E2");

            entity.HasOne(d => d.Reservation).WithMany(p => p.ReservationVehicles)
                .HasForeignKey(d => d.ReservationId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Reservati__Reser__5DCAEF64");

            entity.HasOne(d => d.Vehicle).WithMany(p => p.ReservationVehicles)
                .HasForeignKey(d => d.VehicleId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Reservati__Vehic__5EBF139D");
        });

        modelBuilder.Entity<Review>(entity =>
        {
            entity.HasKey(e => e.ReviewId).HasName("PK__Reviews__74BC79CE711461F2");

            entity.Property(e => e.DatePosted).HasColumnType("datetime");

            entity.HasOne(d => d.User).WithMany(p => p.Reviews)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Reviews__UserId__4AB81AF0");

            entity.HasOne(d => d.Worker).WithMany(p => p.Reviews)
                .HasForeignKey(d => d.WorkerId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Reviews__WorkerI__4D94879B");
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasKey(e => e.RoleId).HasName("PK__Roles__8AFACE1A7F60ED59");
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.UserId).HasName("PK__Users__1788CC4CFDA4BE49");

            entity.HasIndex(e => e.UserTypeId, "IX_Users_UserTypeId");

            entity.HasOne(d => d.UserType).WithMany(p => p.Users)
                .HasForeignKey(d => d.UserTypeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Users__UserTypeI__ABCDEF12");
        });

        modelBuilder.Entity<UserType>(entity =>
        {
            entity.HasKey(e => e.UserTypeId).HasName("PK__UserType__40D2D81612345678");

            entity.ToTable("UserType");
        });

        modelBuilder.Entity<Vehicle>(entity =>
        {
            entity.HasKey(e => e.VehicleId).HasName("PK__Vehicles__476B54927D223A98");

            entity.Property(e => e.PricePerNight).HasColumnType("decimal(18, 2)");
        });

        modelBuilder.Entity<Worker>(entity =>
        {
            entity.HasKey(e => e.WorkerId).HasName("PK__Workers__077C8826ADEFBF7D");

            entity.HasMany(d => d.Roles).WithMany(p => p.Workers)
                .UsingEntity<Dictionary<string, object>>(
                    "WorkerRole",
                    r => r.HasOne<Role>().WithMany()
                        .HasForeignKey("RoleId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK__WorkerRol__RoleI__76543210"),
                    l => l.HasOne<Worker>().WithMany()
                        .HasForeignKey("WorkerId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK__WorkerRol__Worke__01234567"),
                    j =>
                    {
                        j.HasKey("WorkerId", "RoleId").HasName("PK__WorkerRo__E1A8630F89ABCDEF");
                        j.ToTable("WorkerRoles");
                        j.HasIndex(new[] { "RoleId" }, "IX_WorkerRoles_RoleId");
                    });
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
