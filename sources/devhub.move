/// Module: devhub
module devhub::devhub;

use std::string::String;
use sui::event;
use sui::object_table::{Self, ObjectTable};
use sui::package;
use sui::url::Url;

//Errors
const ENotTheOwner: u64 = 1;

//Structs: Shows the individual resume
//Research on whether i can just use Dofs or Ofs for the technologies

public struct DevCard has key, store {
    id: UID,
    name: String,
    title: String,
    owner: address,
    image_url: Url,
    description: String,
    years_of_experience: u64,
    technologies: String,
    portfolio: String,
    contact: String,
    payment: u64,
    open_to_work: bool,
}

//The hub where the cards are posted to get the job
public struct DevHub has key {
    id: UID,
    cards: ObjectTable<String, DevCard>,
}

public struct CardCreated has copy, drop {
    id: ID,
    name: String,
    title: String,
    contact: String,
}

public struct DescriptionUpdated has copy, drop {
    name: String,
    owner: address,
    new_description: String,
}

public struct PortfolioUpdated has copy, drop {
    name: String,
    owner: address,
    new_portfolio: String,
}

public struct DEVHUB has drop {}

fun init(otw: DEVHUB, ctx: &mut TxContext) {
    let publisher = package::claim(otw, ctx);

    let devhub = DevHub {
        id: object::new(ctx),
        cards: object_table::new(ctx),
    };

    transfer::share_object(devhub);
    transfer::public_transfer(publisher, ctx.sender());
}

#[allow(unused_let_mut)]
public fun create_card(
    name: String,
    title: String,
    image_url: Url,
    years_of_experience: u64,
    technologies: String,
    description: String,
    portfolio: String,
    contact: String,
    payment: u64,
    devhub: &mut DevHub,
    ctx: &mut TxContext,
) {
    let mut devCard = DevCard {
        id: object::new(ctx),
        name: name,
        title: title,
        owner: ctx.sender(),
        image_url: image_url,
        description: description,
        years_of_experience: years_of_experience,
        technologies: technologies,
        portfolio: portfolio,
        contact: contact,
        payment: payment,
        open_to_work: true,
    };

    event::emit(CardCreated {
        id: object::id(&devCard),
        name: name,
        title: title,
        contact: contact,
    });

    object_table::add(&mut devhub.cards, name, devCard);
}

public fun update_card_description(
    devcard: &mut DevCard,
    new_description: String,
    ctx: &mut TxContext,
) {
    assert!(ctx.sender() == devcard.owner, ENotTheOwner);

    devcard.description = new_description;

    event::emit(DescriptionUpdated {
        name: devcard.name,
        owner: ctx.sender(),
        new_description: new_description,
    });
}

public fun deactivate_card(devhub: &mut DevHub, name: String, ctx: &mut TxContext) {
    let card = object_table::borrow_mut(&mut devhub.cards, name);
    assert!(card.owner == tx_context::sender(ctx), ENotTheOwner);
    card.open_to_work = false;
}

public fun get_card_info(
    devhub: &DevHub,
    name: String,
): (String, address, String, Url, String, u64, String, String, String, u64, bool) {
    let card = object_table::borrow(&devhub.cards, name);
    (
        card.name,
        card.owner,
        card.title,
        card.image_url,
        card.description,
        card.years_of_experience,
        card.technologies,
        card.portfolio,
        card.contact,
        card.payment,
        card.open_to_work,
    )
}

// For Move coding conventions, see
public fun update_card_portfolio(
    devcard: &mut DevCard,
    new_portfolio: String,
    ctx: &mut TxContext,
) {
    assert!(ctx.sender() == devcard.owner, ENotTheOwner);
    devcard.portfolio = new_portfolio;

    event::emit(PortfolioUpdated {
        name: devcard.name,
        owner: ctx.sender(),
        new_portfolio: devcard.portfolio,
    });
}
// https://docs.sui.io/concepts/sui-move-concepts/conventions
