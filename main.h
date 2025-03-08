#pragma once
#include <array>
#include <cstdint>
#include <bitset>

constexpr uint8_t PlayerCount = 4;
constexpr uint8_t NumberOfClasses = 6;

struct GameStats {
    static constexpr uint8_t MaxStamina = 100;
    static constexpr uint8_t LightAttackStaminaCost = 15;
    static constexpr uint8_t HeavyAttackStaminaCost = 30;
    static constexpr uint8_t DefendStaminaCost = 5;
    static constexpr uint8_t UltimateAttackStaminaCost = 80;

    static constexpr uint8_t HealthGainPerTurn = 5;
    static constexpr uint8_t StaminaGainPerTurn = 10;
    static constexpr uint8_t KnightExtraStaminaGain = 5;

    static constexpr uint8_t BurnDamage = 10;
    static constexpr uint8_t BurnDuration = 2;
    static constexpr uint8_t PoisonDamage = 5;
    static constexpr uint8_t PoisonDuration = 4;

    static constexpr uint8_t VampireLeechChance = 50;
};

enum class AllClasses : uint8_t {
    Knight, Assassin, Pyromancer, Healer, Vanguard, Vampire
};

struct PlayerStats {
    uint8_t Health = 0;
    uint8_t MaxHealth = 0;
    uint8_t LightDamage = 0;
    uint8_t HeavyDamage = 0;
    uint8_t Defense = 0;
    uint8_t CritChance = 0;
    uint8_t UltimateCooldown = 0;
    uint8_t Stamina = GameStats::MaxStamina; // Start with full stamina
};

struct PlayerState {
    PlayerStats Stats;
    std::bitset<8> StatusEffects; // Bitmask burn,poison,paralyse,vitality,rage
    uint8_t BurnForTurns = 0;
    uint8_t PoisonForTurns = 0;
    uint8_t VitalityForTurns = 0;
    uint8_t SelectedChoice = 0;
    bool DidCrit = false;
    uint8_t Target = 0;
    AllClasses SelectedClass;
};

struct GameState {
    std::array<PlayerState, PlayerCount> Players;    
    uint8_t CurrentTurn = 0;
    uint8_t MatchTurn = 0;
    uint8_t TeamSynergies = 0; // Higher nibble for team 1, lower nibble for team 2.
};

struct ClassStats {
    static constexpr std::array<PlayerStats, 6> ClassData = {{
        {85, 85, 20, 35, 30, 30, 1},  // Knight
        {30, 60, 30, 40, 10, 50, 4},  // Assassin
        {50, 50, 20, 30, 20, 30, 4},  // Pyromancer
        {70, 70, 15, 30, 15, 30, 4},  // Healer
        {100, 100, 10, 35, 50, 0, 4}, // Vanguard
        {70, 70, 15, 25, 15, 99, 4}   // Vampire
    }};
    
    static constexpr PlayerStats GetClassStats(AllClasses ClassType) {
        return ClassData[static_cast<size_t>(ClassType)];
    }
};

int main();
