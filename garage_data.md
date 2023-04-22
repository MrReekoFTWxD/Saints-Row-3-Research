## Info

Some structs done for PS3 version of SR3 - I have found a way to save a vehicle im currently in to my garage. Still trying to find a way to spawn/create vehicles
if anyone has any info hmu on discord. 

How I saved vehicles im currently in to my garage from anywhere

![image](https://cdn.discordapp.com/attachments/698690083154559087/1099242493016559687/image.png)

```cpp
struct vehicle_resource_uid
{
    unsigned short m_info_uid;
    unsigned short m_top_level_variant_id;
}; //Size: 0x0004

struct garage_slot_flags
{
    unsigned __int8 reward_vehicle : 1;
    unsigned __int8 smoking : 1;
    unsigned __int8 on_fire : 1;
    unsigned __int8 instance_data_unavailable : 1;
    unsigned __int8 player_customized : 1;
    unsigned __int8 is_customizable : 1;
    unsigned __int8 start_variant_set : 1;
    unsigned __int8 is_new : 1;
};

struct vehicle_cust_description
{
    unsigned __int8 m_data[57];
};

struct garage_vehicle_purchase_data
{
    unsigned __int8 purchased_components_buffer[32];
};

struct garage_slot
{
    object_handle spawned_vehicle_handle;
    unsigned int uid;
    garage_slot_flags flags;
    vehicle_resource_uid m_vehicle_resource_uid;
    unsigned __int16 m_start_vehicle_resource_top_level_variant_id;
    char m_radio_station_id;
    vehicle_cust_description vehicle_cust_sync_packet;
    int vehicle_cust_sync_packet_size;
    garage_vehicle_purchase_data vehicle_purchase_data;
    float retrieval_cost;
    garage_slot* prev;
    garage_slot* next;
};

struct garage
{
    garage_slot* vehicle_slots;
    int num_vehicles;
};

```
