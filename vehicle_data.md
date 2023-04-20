```cpp

struct axle_wheel_info
{
    bool does_steer;
    bool reverse_steer;
    bool does_handbrake;
    char pad_0003[1];
    float engine_torque_factor;
    float mass;
    float friction;
    float ai_friction;
    float max_friction;
    float drifting_friction_modifier;
    float braking_torque;
    float spring_length;
    float spring_strength;
    float spring_max_force;
    float compression_damping;
    float expansion_damping;
    float ramp_compression_damping;
    float min_suspension_length;
    float max_suspension_length;
}; //Size: 0x0040

struct transmission_info
{
    unsigned int num_gears;
    float gear_ratios[6];
    float downshift_rpms[5];
    float upshift_rpm;
    float differential_gear_ratio;
    float reverse_gear_ratio;
    float clutch_delay;
    float m_maximum_rpm_rate;
    char pad_0044[36];
}; //Size: 0x0068

#pragma pack (1)
struct vehicle_info
{
    char name[24];
    unsigned int name_cs;
    unsigned char dlc_bundle;
    char pad_001D[3];
    int m_num_resources;
    int m_not_baked_down_support_num_variants;
    struct vehicle_resource_info* m_resources;
    int m_type;
    char pad_0030[1024];
    char id;
    char _aa[1];
    wchar_t display_name[24];
    char display_bm[24];
    char pad_047A[2];
    int hostage_vehicle_type;
    char pad_0480[20];
    int m_max_hitpoints;
    float chassis_mass;
    float component_density;
    float player_damage_multiplier;
    unsigned int m_value;
    unsigned int m_chop_shop_props;
    unsigned int m_vandal_value;
    unsigned int m_num_lods;
    float m_lod_distance_ratios[4];
    int m_special_type;
    int m_road_preference;
    float engine_torque;
    float min_rpm;
    float optimal_rpm;
    float max_rpm;
    float min_rpm_torque_factor;
    float max_rpm_torque_factor;
    float min_rpm_resistance;
    float opt_rpm_resistance;
    float max_rpm_resistance;
    float clutch_slip_rpm;
    unsigned int m_num_axles;
    struct axle_wheel_info axle_wheel_info[2];
    struct transmission_info trans_info;
    float max_steering_angle;
    float ai_max_steering_angle;
    float max_speed_steering_angle;
    float ai_max_speed_steering_angle;
    float m_steering_wheel_max_speed;
    float m_steering_wheel_max_return_speed;
    float m_steering_wheel_damp_angle;
    char pad_05FC[1084];
    char vi_info_name[64];
    unsigned int vi_info_name_checksum;
    char pad_0A7C[4];
    char character_animation_set_name[64];
    unsigned int character_animation_set_name_checksum;
    char pad_0AC4[188];
}; //Size: 0x0B80
#pragma pack(0)

struct vehicle
{
    char pad_0000[3044];
    vehicle_info* info;
};

```

## What i found
  So everything inside the vehicle_info struct can be modified at run time, doesnt need to be modified before entering sr3_city
  here an img I flipped the turning axial for this car 

![image](https://cdn.discordapp.com/attachments/984506811895926786/1097672717953662996/image.png)
