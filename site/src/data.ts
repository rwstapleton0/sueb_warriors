import { KioskClient, KioskItem, KioskOwnerCap, KioskTransaction } from "@mysten/kiosk";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { useEffect } from "react";

const packageId = "0x5baa221eb91015d3063e8939fbb12d1f48423ecb0a8f87a54677f1e3beae2d7c";
const moduleName = "kiosk_tone";
const suebWarriorObject = "SuebWarrior";
// const suebWarriorObject = "Monbob";

const packageAndModule = `${packageId}::${moduleName}`

export type SuebObject = {
    imageUrl: string,
    name: String,
    energy: number | undefined,
    power: number | undefined,
    rush: number | undefined,
    objectId: string | undefined,
}

export const imageUrls = [
    "QmV7KskYhhQ7JBuNwL1rtGnkDTuWkpqxVhCG5z4ZeNuuTT?filename=sueb_w1.png",
    "QmXCxj1m4nEUigYm6KiCft4UHhDvuWYRLCFfTMLMSLiSVN?filename=sueb_w2.png",
    "QmRS7VShUpQ9JPqtoF1AcJkaGyNpRnaNL3xXsvaDJa4L3M?filename=sueb_w3.png",
    "QmPrd1cBB3oD1akNegyefaZed3L4CwBeaBK2Pn4yXBBFSx?filename=sueb_w4.png",
]

function getRandomInt() {
    return Math.ceil(Math.random() * 10);
}

export function createKiosk(
    address: string | undefined,
    kioskClient: KioskClient,
    signAndExecuteTransactionBlock: Function
) {
    if (address == undefined) {
        return
    }

    const txb = new TransactionBlock();
    const kioskTx = new KioskTransaction({ transactionBlock: txb, kioskClient });

    kioskTx.create();

    kioskTx.shareAndTransferCap(address);

    kioskTx.finalize();

    signAndExecuteTransactionBlock({ transactionBlock: txb });
}

export function useGetKiosks(account: any | null, kioskClient: KioskClient, setKiosk: Function) {
    useEffect(() => { // should need to get this to watch for updates.
        if (account == null) {
            return
        }
        const address = account.address;

        async function getKiosk() {
            const { kioskOwnerCaps } = await kioskClient.getOwnedKiosks({ address });

            setKiosk(kioskOwnerCaps)
        }
        getKiosk();
    }, [account])
}

export function useGetKioskData(
    kioskCap: KioskOwnerCap | undefined,
    kioskClient: KioskClient,
    setKioskData: Function
) {
    useEffect(() => { // better way of doing this?
        if (kioskCap === undefined) {
            return
        }
        async function getKioskItems() {

            const res = await kioskClient.getKiosk({
                id: kioskCap?.kioskId || "",
                options: { // way to filter for sueb here?
                    withObjects: true,
                }
            });
            let items = res.items.filter((item: KioskItem) =>
                item.type == `${packageAndModule}::${suebWarriorObject}`)

            setKioskData(items);
        }
        getKioskItems();
    }, [kioskCap?.kioskId])
}

export async function mintSuebInKiosk(
    name: string,
    type: number,
    cap: KioskOwnerCap,
    kioskClient: KioskClient,
    signAndExecuteTransactionBlock: Function
) {
    const energy = getRandomInt(); 
    const power = getRandomInt(); 
    const rush = getRandomInt(); 

    const txb = new TransactionBlock();
    const kioskTx = new KioskTransaction({ kioskClient, transactionBlock: txb, cap });

    txb.moveCall({
        target: `${packageAndModule}::mint_sueb_to_kiosk`,
        arguments: [
            txb.pure(name),
            txb.pure(energy),
            txb.pure(power),
            txb.pure(rush),
            txb.pure(imageUrls[type]),
            kioskTx.getKiosk(),
            kioskTx.getKioskCap()
        ],
    });

    kioskTx.finalize();

    await signAndExecuteTransactionBlock(
        {
            transactionBlock: txb,
            chain: 'sui:testnet',
        },
        {
            onSuccess: (result: { digest: any; }) => {
                console.log('executed transaction block', result);
            },
        },
    );
}